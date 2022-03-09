import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/live/broadcast_info.dart';
import 'package:live812/domain/model/live/live.dart';
import 'package:live812/domain/model/live/liver_category.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/services/api_path.dart';
import 'package:live812/domain/usecase/beautification_usecase.dart';
import 'package:live812/ui/scenes/live/live_preview_page.dart';
import 'package:live812/ui/scenes/live/live_stream.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/date_format.dart';
import 'package:live812/utils/keyboard_util.dart';
import 'package:live812/utils/on_memory_cache.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/share_util.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:loading_indicator_view/loading_indicator_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

enum _CategoryLoadingState {
  Loading,
  Failed,
  Succeeded,
}

String _getCategoryLoadingMessage(_CategoryLoadingState state) {
  switch (state) {
    case _CategoryLoadingState.Loading:
      return '読み込み中…';
    case _CategoryLoadingState.Failed:
      return 'カテゴリ読み込みに失敗しました';
    case _CategoryLoadingState.Succeeded:
      return 'カテゴリ選択（必須）';
    default:
      return null;
  }
}

class LiveFormPage extends StatefulWidget {
  final void Function({
    BroadcastInfo broadcastInfo,
    CameraType cameraType,
    bool isPortrait,
    bool enableBeautification,
  }) callback;

  LiveFormPage({
    this.callback,
  });

  @override
  _LiveFormPageState createState() => _LiveFormPageState();
}

class _LiveFormPageState extends State<LiveFormPage> {

  static const _MAX_HASH_TAG_LENGTH = 10;

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _isLoading = false;
  bool _cancelEnable = false;
  Map<String, String> map = HashMap();
  CameraType _cameraType = CameraType.InCamera;
  bool _isPortrait = true;
  bool _enableBeautification = false;
  Timer _liveStartWaitTimer;
  _CategoryLoadingState _categoryLoadingState = _CategoryLoadingState.Loading;
  List<LiverCategoryModel> _categories;
  List<String> _selectedCategories = [];
  String _eventId = 'event';
  String _beginnerId = 'beginner';
  bool _selectedCategoryError = true;

  final TextEditingController _tag1Controller = TextEditingController();
  final TextEditingController _tag2Controller = TextEditingController();

  Timer _timer;
  bool _disableBackKey = false;

  BroadcastInfo _broadcastInfo;

  // リレーイベントの配信時間.
  DateTime _relayStartDate;
  DateTime _relayEndDate;

  @override
  void initState() {
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    _requestLiverCategory();
  }

  @override
  void dispose() {
    super.dispose();
    _tag1Controller?.clear();
    _tag2Controller?.clear();
  }

  @override
  Widget build(BuildContext context) {
    double cellWidth = ((MediaQuery.of(context).size.width - 40) / 3);
    double desiredCellHeight = 50;
    double childAspectRatio = cellWidth / desiredCellHeight;

    return LiveScaffold(
        backgroundColor: ColorLive.MAIN_BG,
        title: Lang.LIVE_BROADCAST,
        titleColor: Colors.white,
        onClickBack: !_disableBackKey ? null : () {},
        // バックキーを無効にするか？
        body: WillPopScope(
          onWillPop: () => Future.value(!_disableBackKey),
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 60,
                ),
                child: Form(
                  key: _formKey,
                  autovalidate: _autoValidate,
                  child: Column(
                    children: <Widget>[
                      if ((_relayStartDate != null) && (_relayEndDate != null))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          child: _buildRelayEventScheduleField(),
                        ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          "利用規約に基づくライブ配信を行いましょう。24時間体制でパトロール監視を行っており、露出などの規約違反がある場合は配信停止またはアカウント停止を行う場合があります。",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const Divider(
                        height: 20,
                        color: ColorLive.DIVIDER,
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          "配信カテゴリ\n（配信内容に合わせてカテゴリを選択してください。最大で2つまで選択できます。）",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // カテゴリ選択.
                      _categoryLoadingState == _CategoryLoadingState.Failed
                          ? _categoryReloadButton()
                          : GridView.count(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              crossAxisCount: 3,
                              childAspectRatio: childAspectRatio,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                              children: List.generate(
                                _categories?.length ?? 0,
                                (index) {
                                  var category = _categories[index];
                                  var selected = _selectedCategories
                                          .indexOf(_categories[index].id) >=
                                      0;
                                  if ((category.id == _beginnerId) ||
                                      (category.id == _eventId)) {
                                    return RaisedButton(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          category.name,
                                          style: category.isForced
                                              ? const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                )
                                              : const TextStyle(
                                                  color: ColorLive.BORDER2,
                                                  fontSize: 12),
                                        ),
                                      ),
                                      color: ColorLive.LIGHT_BLUE,
                                      disabledColor: category.isForced
                                          ? ColorLive.LIGHT_BLUE
                                          : ColorLive.BLUE_BG,
                                      shape: category.isForced
                                          ? const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: ColorLive.LIGHT_BLUE,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                            )
                                          : OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.white.withAlpha(20),
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                            ),
                                      onPressed: null,
                                    );
                                  }
                                  return _LiveFormCategoryButton(
                                    name: category.name,
                                    selected: selected || category.isForced,
                                    onPressed: () async {
                                      if (!category.isForced) {
                                        await _selectCategory(!selected, category);
                                      }
                                    },
                                  );
                                },
                              ).toList(),
                            ),
                      _selectedCategoryError
                          ? Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  const Text(
                                      '選択されているカテゴリが足りません。\n自動で選択されているカテゴリ（ビギナー・公式イベント）はカウントされません。',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12))
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          "配信テーマ（配信に入る前に表示されるタグです）",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildHashTagField(controller: _tag1Controller),
                      const SizedBox(height: 10),
                      _buildHashTagField(controller: _tag2Controller),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          "カメラの設定",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _cameraTypeRadioButton(
                              "インカメラ",
                              "camera_front",
                              selected: _cameraType == CameraType.InCamera,
                              onPressed: () => setState(() {
                                _cameraType = CameraType.InCamera;
                              }),
                            ),
                            _cameraTypeRadioButton(
                              "外カメラ",
                              "camera_back",
                              selected: _cameraType == CameraType.OutCamera,
                              onPressed: () => setState(() {
                                _cameraType = CameraType.OutCamera;
                              }),
                            ),
                            _cameraTypeRadioButton(
                              "音声のみ",
                              "sound",
                              selected: _cameraType == CameraType.MicOnly,
                              onPressed: () => setState(() {
                                _cameraType = CameraType.MicOnly;
                                _isPortrait = true;
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          "配信方向の設定",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _orientationTypeRadioButton(
                              "縦向きで配信",
                              "tate",
                              selected: _isPortrait,
                              onPressed: () =>
                                  setState(() => _isPortrait = true),
                            ),
                            _orientationTypeRadioButton(
                              "横向きで配信",
                              "yoko",
                              selected: !_isPortrait,
                              onPressed: _cameraType == CameraType.MicOnly
                                  ? null
                                  : () => setState(() => _isPortrait = false),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          "美顔の設定",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          '美顔機能のオン・オフを選択してください。\nオフの場合は、配信中に美顔機能を使用できません。',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'オフ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    CupertinoSwitch(
                                      value: _enableBeautification,
                                      activeColor: ColorLive.LIGHT_BLUE,
                                      onChanged: (value) async {
                                        await BeautificationUseCase.setEnable(value);
                                        setState(() {
                                          _enableBeautification = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'オン',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 95,
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(20),
                                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                                  border: Border.all(
                                    color: _enableBeautification
                                        ? ColorLive.LIGHT_BLUE
                                        : ColorLive.BORDER2,
                                    width: 1,
                                  ),
                                ),
                                child: RawMaterialButton(
                                  onPressed: _enableBeautification
                                      ? () async {
                                          if (!await _requestPermissions()) {
                                            return;
                                          }
                                          Navigator.of(context).push(
                                            FadeRoute(
                                              builder: (context) =>
                                                  LivePreviewPage(),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SvgPicture.asset(
                                          "assets/svg/menu/face_${_enableBeautification ? "on" : "off"}.svg"),
                                      Text(
                                        '美顔設定',
                                        style: TextStyle(
                                          color: _enableBeautification
                                              ? ColorLive.LIGHT_BLUE
                                              : ColorLive.BORDER2,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "プロフィールをシェアする",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const Text(
                        "こちらはアフィリエイトリンクではございません",
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      const SizedBox(height: 10),
                      _buildShareButtons(context),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 60.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      //end: Alignment.centerRight,s
                      colors: _canStart()
                          ? [ColorLive.BLUE, ColorLive.BLUE_GR]
                          : [ColorLive.C26, ColorLive.C26],
                    ),
                  ),
                  child: FlatButton(
                    textColor: Colors.white,
                    onPressed: () {
                      _validateStartLive();
                    },
                    child: const Text(
                      Lang.START_LIVE,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              _isLoading
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Color.fromARGB(200, 0, 0, 0),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            BallSpinFadeLoaderIndicator(),
                            const SizedBox(
                              height: 16.0,
                            ),
                            const Text(
                              '配信準備中です。',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18.0),
                            ),
                            const Text(
                              '数秒〜３分程かかる場合があります。',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18.0),
                            ),
                            const SizedBox(
                              height: 16.0,
                            ),
                            !_cancelEnable
                                ? Container(height: 48)
                                : MaterialButton(
                                    minWidth: 20,
                                    height: 48,
                                    onPressed: () {
                                      if (_timer != null) {
                                        _timer.cancel();
                                        _timer = null;
                                      }
                                      setState(() {
                                        if (_liveStartWaitTimer != null) {
                                          _liveStartWaitTimer.cancel();
                                          _liveStartWaitTimer = null;
                                        }
                                        _isLoading = false;
                                        _cancelEnable = false;
                                        _disableBackKey = false;
                                      });
                                    },
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    color: ColorLive.BLUE,
                                    child: const Text(
                                      Lang.CANCEL,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                          ],
                        ),
                      ))
                  : Container(),
            ],
          ),
        ));
  }

  Widget _buildRelayEventScheduleField() {
    final statements = [
      'リレー(イベント)開始5分前に配信中の場合は、強制的に終了されます。',
      '配信開始時刻の1分前から配信ルームで待機することができ、配信開始時刻までの時間を確認できます。',
      '配信開始後、残り時間が画面に表示されています。',
      'リレー(イベント)参加中は、ご自身の配信終了後でも、イベントが終了するまでは、配信ができません。',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorLive.BLUE_BG,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: ColorLive.ORANGE,
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: const Text(
              'あなたのリレー(イベント)配信予定',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${dateFormatLiveEventRelay(_relayStartDate)}〜${dateFormatTime(_relayEndDate)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 5),
          Column(
            children: statements.map((statement) =>
              Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '・',
                  style: TextStyle(
                    color: ColorLive.TAB_SELECT_BG_EVENT,
                    fontSize: 12,
                  ),
                ),
                Expanded(
                  child: Text(
                    statement,
                    style: const TextStyle(
                      color: ColorLive.TAB_SELECT_BG_EVENT,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHashTagField({TextEditingController controller}) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding: const EdgeInsets.only(
        top: 3,
      ),
      decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          border: Border.all(color: ColorLive.background, width: 1)),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            prefixIcon: Container(
              padding: const EdgeInsets.only(top: 5, bottom: 12),
              child: SvgPicture.asset(
                "assets/svg/hash.svg",
              ),
            ),
            hintText: Lang.HINT_HASH_TAG,
            labelStyle: const TextStyle(color: Colors.white, fontSize: 16),
            hintStyle: const TextStyle(color: ColorLive.BORDER2, fontSize: 16),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
        inputFormatters: [
          new LengthLimitingTextInputFormatter(_MAX_HASH_TAG_LENGTH),
        ],
      ),
    );
  }

  Widget _buildShareButtons(BuildContext context) {
    return Container(
      width: 180,
      child: PrimaryButton(
        text: 'シェアする',
        height: 32,
        round: true,
        onPressed: () {
          _share();
        },
      ),
    );
  }

  Future _selectCategory(bool selected, LiverCategoryModel category) async {
    if (category.id == _beginnerId) {
      return;
    }
    if (selected) {
      if (_selectedCategories.where((x) => x != _beginnerId).length >= 2) {
        return;
      }
      _selectedCategories.add(category.id);
    } else {
      _selectedCategories.removeWhere((x) => x == category.id);
    }
    _selectedCategoryError =
        _selectedCategories.where((x) => x != _beginnerId).length < 1;
    setState(() {});
  }

  Future<void> _share() async {
    KeyboardUtil.close(context);
    final userModel = Provider.of<UserModel>(context, listen: false);
    final tags = [_tag1Controller.text, _tag2Controller.text];
    final info = ShareUtil.generateUserShareInfo(userModel, tags: tags);
    var text = info.item1;
    final tagStr = info.item2;
    final url = info.item3;
    if (tagStr.isNotEmpty) {
      text = '$text $tagStr';
    }
    await Share.share('$text\n$url');
  }

  Future<void> _validateStartLive() async {
    KeyboardUtil.close(context);
    if (_formKey.currentState.validate()) {
      if (!await _requestPermissions()) {
        return;
      }

      if (!_canStart()) {
        setState(() {});
        return;
      }

      final selected =
          _selectedCategories.where((x) => x != _beginnerId).toList();
      final result = await _createLiveRoom(
        LiveModel(
          960,
          1280,
          selected[0],
          selected.length >= 2 ? selected[1] : null,
          isBeginner: _categories.firstWhere((x) => x.id == _beginnerId, orElse: () => null)?.isForced ?? false,
          isEvent: _categories.firstWhere((x) => x.id == _eventId, orElse: () => null)?.isForced ?? false,
          tag1: _tag1Controller.text.toString(),
          tag2: _tag2Controller.text.toString(),
        ),
      );
      if (result) {
        assert(_broadcastInfo != null);
        widget.callback(
          broadcastInfo: _broadcastInfo,
          cameraType: _cameraType,
          isPortrait: _isPortrait,
          enableBeautification: _enableBeautification,
        );
      }
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  bool _canStart() {
    var length = _selectedCategories.where((x) => x != _beginnerId).length;
    return (length == 1) || (length == 2);
  }

  Widget _categoryReloadButton() {
    return MaterialButton(
      minWidth: double.infinity,
      height: 56,
      onPressed: () {
        KeyboardUtil.close(context);
        _requestLiverCategory();
      },
      padding: const EdgeInsets.symmetric(horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      color: ColorLive.C555,
      child: const Text(
        'カテゴリ取得失敗：リロード',
        style: TextStyle(color: ColorLive.RED, fontSize: 16),
      ),
    );
  }

  Widget _cameraTypeRadioButton(String text, String svgName,
      {bool selected, void Function() onPressed}) {
    final color = selected ? ColorLive.LIGHT_BLUE : ColorLive.BORDER2;
    return Container(
      height: 95,
      width: 95,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        border: Border.all(color: color, width: 1),
      ),
      child: RawMaterialButton(
        onPressed: () {
          KeyboardUtil.close(context);
          onPressed();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              "assets/svg/menu/$svgName${selected ? '_active' : ''}.svg",
            ),
            Text(
              text,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orientationTypeRadioButton(String text, String svgName,
      {bool selected, void Function() onPressed}) {
    final color = selected ? ColorLive.LIGHT_BLUE : ColorLive.BORDER2;
    return Expanded(
      child: Container(
        height: 95,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          border: Border.all(color: color, width: 1),
        ),
        child: RawMaterialButton(
          onPressed: onPressed == null
              ? null
              : () {
                  KeyboardUtil.close(context);
                  onPressed();
                },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                  "assets/svg/menu/$svgName${selected ? '_active' : ''}.svg"),
              Text(
                text,
                style: TextStyle(color: color, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestLiverCategory() async {
    _enableBeautification = await BeautificationUseCase.getEnable();
    setState(() {
      _categoryLoadingState = _CategoryLoadingState.Loading;
    });
    final response = await OnMemoryCache.fetch(
      ApiPath.liverCategory,
      Duration(hours: 1),
      () async {
        final service = BackendService(context);
        final response = await service.getLiverCategory();
        return response?.result == true ? response : null;
      },
      force: true,
    );
    if (response?.result == true) {
      setState(() {
        _categories = response
            .getData()
            .map<LiverCategoryModel>((f) => LiverCategoryModel.fromJson(f))
            .toList();
        // ビギナーを一番最後へ.
        var beginner = _categories.firstWhere((x) => x.id == _beginnerId,
            orElse: () => null);
        if (beginner != null) {
          if (_categories.remove(beginner)) {
            _categories.add(beginner);
          }
        }
        _categoryLoadingState = _CategoryLoadingState.Succeeded;
        // リレーイベント.
        final subData = response.getByKey('subdata') as Map<String, dynamic>;
        if (subData != null) {
          final events = subData['event'] as List<dynamic>;
          if (events != null) {
            for(Map<String, dynamic> event in events) {
              if ((event['live_start_date'] != null) &&
                  (event['live_end_date'] != null)) {
                _relayStartDate = DateTime.parse(event['live_start_date']);
                _relayEndDate = DateTime.parse(event['live_end_date']);
                break;
              }
            }
          }
        }
      });
      return;
    } else {
      setState(() {
        _categoryLoadingState = _CategoryLoadingState.Failed;
      });
    }
  }

  // 必要なパーミッションが許可されているかどうか調べる
  Future<bool> _requestPermissions() async {
    final permissionHandler = PermissionHandler();
    final status = await permissionHandler.requestPermissions(
        [PermissionGroup.camera, PermissionGroup.microphone]);
    if (status != null &&
        status.keys.every((key) => status[key] == PermissionStatus.granted)) {
      return true;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("パーミッションエラー"),
          content: const Text(
              'ライブの配信に必要な権限（カメラ、マイク）を与えてください。\n権限の変更は本体の設定から行ってください。'),
          actions: <Widget>[
            FlatButton(
              child: const Text("設定を開く"),
              onPressed: () => permissionHandler.openAppSettings(),
            ),
            FlatButton(
              child: const Text("閉じる"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
    return false;
  }

  Future<bool> _createLiveRoom(LiveModel model) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final service = BackendService(context);
    setState(() {
      _isLoading = true;
      _disableBackKey = true;
      _cancelEnable = false;
    });
    final response = await service.postLiveRoom(model);
    String error = '通信エラーが発生しました。電波状況をご確認の上、再度アクセスしてください。';
    if (response != null && response.result) {
      final broadcastInfo = BroadcastInfo.fromJson(response.getData());
      if (broadcastInfo.liveId != null) {
        // 配信開始
        final response2 = await service.postLiveStart(
            liveId: broadcastInfo.liveId,
            userId: userModel.id,
            isLandscape: !_isPortrait,
            cameraOff: _cameraType == CameraType.MicOnly);
        if (response2 != null && response2.result) {
          _broadcastInfo = broadcastInfo;
          // 成功の場合はどうせ遷移してしまうので、変数だけ戻してローディングは出したままにしておこう
          final response3 =
              await service.postStreamingLiveBroadcast(broadcastInfo.liveId);
          if (response3 != null && response3.result) {
            return true;
          }
        } else {
          print('postLiveStart: false');
          print(response2);
          if (response2.containsKey('msg')) {
            error = response2.getByKey('msg');
          }
        }
      } else {
        if (response.containsKey('msg')) {
          error = response.getByKey('msg');
        }
      }
    } else {
      if (response.containsKey('msg')) {
        error = response.getByKey('msg');
      }
    }

    setState(() {
      _isLoading = false;
      _disableBackKey = false;
    });
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("エラーが発生しました"),
          content:
              Text('$error'),
          actions: <Widget>[
            FlatButton(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );

    // エラーだった場合次の画面へ遷移しない
    return false;
  }
}

class _LiveFormCategoryButton extends StatelessWidget {
  const _LiveFormCategoryButton({
    this.name,
    this.selected,
    this.onPressed,
  });

  final String name;
  final bool selected;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          name,
          style: selected
              ? const TextStyle(
                  color: ColorLive.LIGHT_BLUE,
                  fontSize: 12,
                )
              : const TextStyle(
                  color: ColorLive.BORDER2,
                  fontSize: 12,
                ),
        ),
      ),
      color: ColorLive.BLUE_BG,
      shape: selected
          ? const OutlineInputBorder(
              borderSide: BorderSide(
                color: ColorLive.LIGHT_BLUE,
              ),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            )
          : const OutlineInputBorder(
              borderSide: BorderSide(
                color: ColorLive.BORDER2,
              ),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
      onPressed: onPressed,
    );
  }
}