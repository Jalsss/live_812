import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live812/domain/model/user/badge_info.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/services/api_path.dart';
import 'package:live812/domain/usecase/jasrac_usecase.dart';
import 'package:live812/ui/scenes/user/liver/liver_withdraw_page.dart';
import 'package:live812/ui/scenes/user/monthly_rank_page.dart';
import 'package:live812/ui/scenes/user/profile_edit_page.dart';
import 'package:live812/ui/scenes/user/profile_view.dart';
import 'package:live812/ui/scenes/user/widget/follower_ranking_fanrank.dart';
import 'package:live812/utils/comma_format.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/image_util.dart';
import 'package:live812/utils/on_memory_cache.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/super_text_util.dart';
import 'package:live812/utils/widget/exclamation_badge.dart';
import 'package:live812/utils/widget/safe_network_image.dart';
import 'package:live812/utils/widget/spinning_indicator.dart';
import 'package:live812/utils/widget/web_view_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:live812/ui/scenes/user/widget/list_icon_badge_widget.dart';
import 'package:live812/ui/scenes/user/model/icon_badge_model.dart';

class MyPage extends StatefulWidget {
  final void Function(Function) onSetUp;

  MyPage({this.onSetUp});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage>
    with AutomaticKeepAliveClientMixin<MyPage> {
  bool _isLiver = false;
  String _prevProfile;
  List<SuperText> _profileSuperText;
  bool _isShowLongProfile = false;
  File _updateProfileImage;
  bool _isImageUploading = false;
  int _followerCount;
  int _benefit;
  String _monthlyRanking;
  bool _isLoading = false;
  bool showAllBadge = false;
  List<IconBadge> listIcon = [];
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    if (widget.onSetUp != null) {
      widget.onSetUp(() {
        _startRequest();
      });
    }

    _startRequest();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        _buildMain(context),
        !_isImageUploading ? null : SpinningIndicator(),
      ].where((w) => w != null).toList(),
    );
  }


  Widget _buildMain(BuildContext context) {
    final profileTextStyle = const TextStyle(color: Colors.white, fontSize: 14);

    return Consumer<UserModel>(
      builder: (context, userModel, _) {
        _isLiver = userModel?.isLiver ?? true;
        if (_prevProfile != userModel?.profile) {
          _prevProfile = userModel?.profile;
          if (_prevProfile != null)
            _profileSuperText = SuperTextUtil.parse(userModel?.profile);
        }
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: ListView(
            padding: EdgeInsets.only(bottom: 120),
            children: <Widget>[
              _userInfoRow(context),
              _divider(height: 22),
              SuperTextWidget(
                _profileSuperText,
                maxLines: _isShowLongProfile ? null : 2,
                textAlign: TextAlign.center,
              ),
              LayoutBuilder(builder: (context, size) {
                final textPainter = TextPainter(
                  text: TextSpan(
                    text: userModel?.profile ?? "",
                    style: profileTextStyle,
                  ),
                  maxLines: 2,
                  textDirection: TextDirection.ltr,
                );
                textPainter.layout(maxWidth: size.maxWidth);
                if (textPainter.didExceedMaxLines) {
                  return (userModel?.profile ?? "").length <= 0
                      ? null
                      : MaterialButton(
                          onPressed: () {
                            setState(() {
                              _isShowLongProfile = !_isShowLongProfile;
                            });
                          },
                          padding: EdgeInsets.all(0),
                          child: Text(
                            _isShowLongProfile ? "戻る" : "…もっと見る",
                            style:
                                TextStyle(color: ColorLive.BLUE, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        );
                } else {
                  return Container();
                }
              }),
              Center(
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  color: ColorLive.background,
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text("プロフィールを編集"),
                  onPressed: () => _editProfilePage(userModel),
                ),
              ),
              SizedBox(height: 9),
              listIcon.length > 0 ? ListIconBadge(listIconBadge: listIcon,
                showAllBadge : showAllBadge, showAll: () {
                setState(() {
                  showAllBadge = !showAllBadge;
                });
              },) : SizedBox(),
              !_isLiver ? null : _monthlyLiveTimeRow(context, userModel),
              !_isLiver ? null : _monthlyGiftPointRow(context, userModel),
              _divider(height: 22),
              _balanceRow(context, userModel),
              //!_isLiver ? null : _withdrawRow(context, userModel),
              !_isLiver
                  ? null
                  : _liverFollowerMonthlyRanking(context, userModel),
              SizedBox(height: 9),
              // メニュー：各項目
              // ランキング.
              _isLiver
                  ? Container()
                  : InkWell(
                      child: Column(
                        children: <Widget>[
                          const Divider(
                            height: 0.5,
                            thickness: 0.5,
                            color: ColorLive.DIVIDER,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 18),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    "\u{1F3C6}ランキング",
                                    style: const TextStyle(
                                        color: Color(0xFFFFFF00),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: ColorLive.ORANGE,
                                  size: 16,
                                ),
                              ].where((w) => w != null).toList(),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          FadeRoute(
                            builder: (context) => MonthlyRankPage(
                              userId: userModel.id,
                            ),
                          ),
                        );
                      },
                    ),
              // フォロー中
              _buttonElement(
                Lang.FOLLOWING,
                onPressed: () {
                  Navigator.pushNamed(context, '/mypage/following');
                },
              ),
              // ストア.
              Consumer<BadgeInfo>(
                builder: (context, badgeInfo, _) {
                  return _buttonElement(
                    Lang.STORE,
                    onPressed: () {
                      Navigator.pushNamed(context, '/shop');
                    },
                    additionalIcon: badgeInfo.sales || badgeInfo.purchase || badgeInfo.chat
                        ? ExclamationBadge()
                        : null,
                  );
                },
              ),
              // 楽曲利用申請.
              !_isLiver
                  ? Container()
                  : _buttonElement(
                      '楽曲利用申請',
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        final token =
                            await JasracUseCase.requestWebToken(context);
                        setState(() {
                          _isLoading = false;
                        });
                        if ((token == null) || (token.isEmpty)) {
                          await JasracUseCase.showMessage(
                              context, 'エラー', 'ウェブトークンの取得に失敗しました');
                          return;
                        }
                        await JasracUseCase.transitionJasrac(context, token);
                      },
                    ),
              // Q&A.
              _buttonElement(
                Lang.QUESTION_AND_ANSWER,
                onPressed: () async {
                  var url = _isLiver
                      ? "https://live812.jp/q_a/qa.html?liver"
                      : "https://live812.jp/q_a/qa.html?listener";
                  await Navigator.push(
                    context,
                    FadeRoute(
                      builder: (context) => WebViewPage(
                        url: url,
                        titleColor: Colors.white,
                        title: Lang.QUESTION_AND_ANSWER,
                        appBarColor: ColorLive.MAIN_BG,
                        toGivePermissionJs: true,
                      ),
                    ),
                  ); // ヘルプ・使い方
                },
              ),
              // 設定
              _buttonElement(
                Lang.SETTING,
                onPressed: () => Navigator.pushNamed(context, '/setting'),
              ),
              _divider(),
            ].where((widget) => widget != null).toList(),
          ),
        );
      },
    );
  }

  // ユーザ情報：アイコン、ニックネーム、お知らせボタン
  Widget _userInfoRow(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, userModel, _) {
        return Row(
          children: <Widget>[
            SizedBox(
              width: 80,
              height: 80,
              child: RawMaterialButton(
                onPressed: () {
                  showSelectDialog();
                },
                elevation: 2,
                padding: EdgeInsets.all(2),
                shape: CircleBorder(),
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage: _updateProfileImage != null
                      ? FileImage(_updateProfileImage)
                      : SafeNetworkImage(
                          BackendService.getUserThumbnailUrl(userModel.id)),
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: !_isLiver
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfileViewPage(userId: userModel.id),
                          ),
                        );
                      },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      userModel.nickname ?? '-',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      userModel.symbol ?? '-',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Roboto",
                          fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              child: Stack(
                children: [
                  SizedBox(
                    width: 40,
                    child: RawMaterialButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/mypage/notice');
                      },
                      elevation: 2,
                      padding: EdgeInsets.all(10),
                      shape: CircleBorder(),
                      child:
                          SvgPicture.asset("assets/svg/alert.svg", height: 24),
                    ),
                  ),
                  // バッジ
                  Consumer<BadgeInfo>(
                    builder: (context, badgeInfo, _) {
                      return !badgeInfo.myPageBell
                          ? Container()
                          : Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                margin: EdgeInsets.only(right: 3),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Center(
                                  child: Text('!',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                ),
                              ),
                            );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // 今月配信時間合計
  Widget _monthlyLiveTimeRow(BuildContext context, UserModel userModel) {
    final int monthlyLiveTime = userModel?.monthlyLiveTime ?? 0;
    final int hours = (monthlyLiveTime / 60).floor();
    final int minutes = (monthlyLiveTime % 60).floor();

    return Column(
      children: [
        _divider(height: 22),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                Lang.THIS_MONTH_LIVE_TIME,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ),
            hours == 0
                ? Container()
                : Text(
                    commaFormat(hours),
                    style: TextStyle(
                        color: ColorLive.ORANGE,
                        fontSize: 26,
                        fontFamily: "Roboto"),
                  ),
            hours == 0
                ? Container()
                : Text(
                    " " + Lang.HOURS + " ",
                    style: TextStyle(color: ColorLive.ORANGE, fontSize: 12),
                  ),
            Text(
              commaFormat(minutes),
              style: TextStyle(
                  color: ColorLive.ORANGE, fontSize: 26, fontFamily: "Roboto"),
            ),
            Text(
              " " + Lang.MINUTES,
              style: TextStyle(color: ColorLive.ORANGE, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  // 今月獲得ギフト
  Widget _monthlyGiftPointRow(BuildContext context, UserModel userModel) {
    return Column(
      children: [
        _divider(height: 22),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                Lang.THIS_MONTH_GIFT_POINT,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              commaFormat(userModel?.monthlyGiftPoint ?? 0),
              style: TextStyle(
                  color: ColorLive.ORANGE, fontSize: 26, fontFamily: "Roboto"),
            ),
            Text(
              " " + Lang.COIN,
              style: TextStyle(color: ColorLive.ORANGE, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  // 残高
  Widget _balanceRow(BuildContext context, UserModel userModel) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            Lang.BALANCE,
            style: TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          commaFormat(userModel?.point ?? 0),
          style: TextStyle(
              color: ColorLive.ORANGE, fontSize: 26, fontFamily: "Roboto"),
        ),
        Text(
          " " + Lang.COIN,
          style: TextStyle(color: ColorLive.ORANGE, fontSize: 12),
        ),
        SizedBox(width: 10),
        MaterialButton(
          minWidth: 20,
          onPressed: () async {
            await Navigator.pushNamed(context, '/mypage/coin/history');
            // 履歴ページでコインが更新されると反映されないので、念の為状態を画面に反映
            setState(() {});
          },
          padding: EdgeInsets.symmetric(horizontal: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          color: ColorLive.ORANGE,
          child: Text(
            Lang.HISTORY,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        SizedBox(width: 8),
        MaterialButton(
          minWidth: 20,
          onPressed: () {
            Navigator.pushNamed(context, '/mypage/coin/charge');
          },
          padding: EdgeInsets.symmetric(horizontal: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          color: ColorLive.ORANGE,
          child: Text(
            Lang.CHARGE,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  // ライバー：出金
  Widget withdrawRow(BuildContext context, UserModel userModel) {
    return Column(
      children: <Widget>[
        _divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              Lang.WITHDRAW_AMOUNT,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
            Row(
              children: <Widget>[
                Text(
                  _benefit != null ? commaFormat(_benefit) : '-',
                  style: TextStyle(
                      color: ColorLive.ORANGE,
                      fontSize: 22,
                      fontFamily: "Roboto"),
                ),
                Text(
                  " " + Lang.YEN,
                  style: TextStyle(color: ColorLive.ORANGE, fontSize: 12),
                ),
                SizedBox(width: 10),
                MaterialButton(
                  minWidth: 80,
                  onPressed: () {
                    Navigator.push(
                        context,
                        FadeRoute(
                            builder: (context) => LiverWithdrawPage(_benefit)));
                  },
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  color: ColorLive.ORANGE,
                  child: Text(
                    Lang.DO_WITHDRAW,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        // 振込予定額：現状マイページではわからないので、コメントアウト
        //Row(
        //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //  children: <Widget>[
        //    Text(
        //      Lang.WITHDRAW_ESTIMATE_AMOUNT,
        //      style: TextStyle(
        //          color: Colors.white,
        //          fontSize: 12,
        //          fontWeight: FontWeight.w700),
        //    ),
        //    Row(
        //      children: <Widget>[
        //        Text(
        //          commaFormat(12345),
        //          style: TextStyle(
        //              color: Colors.white,
        //              fontSize: 22,
        //              fontFamily: "Roboto"),
        //        ),
        //        Text(
        //          " " + Lang.YEN,
        //          style: TextStyle(color: Colors.white, fontSize: 12),
        //        ),
        //        SizedBox(width: 10),
        //        Container(
        //          width: 80,
        //          child: Center(
        //            child: Text(
        //              '(2020/02/28)',
        //              style: TextStyle(color: Colors.white, fontSize: 12),
        //            ),
        //          ),
        //        ),
        //      ],
        //    ),
        //  ],
        //),
      ],
    );
  }

  Widget _liverFollowerMonthlyRanking(
      BuildContext context, UserModel userModel) {
    return Column(
      children: [
        _divider(),
        SizedBox(height: 9),
        FollowerRankingFanrankView(
          followerCount: _followerCount,
          monthlyRanking: _monthlyRanking,
          userId: userModel.id,
        ),
      ],
    );
  }

  // ボタン要素
  Widget _buttonElement(String text,
      {Function onPressed, Widget additionalIcon}) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: <Widget>[
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: ColorLive.DIVIDER,
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                additionalIcon,
                Icon(
                  Icons.arrow_forward_ios,
                  color: ColorLive.ORANGE,
                  size: 16,
                ),
              ].where((w) => w != null).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 区切り線
  Divider _divider({color: ColorLive.DIVIDER, double height: 0.5}) {
    return Divider(
      color: color,
      height: height,
      thickness: 0.5,
    );
  }

  // --------- プロフィール画像変更 ---------
  Future<void> _getImageFromCamera() async {
    var image = await ImageUtil.pickImage(context, ImageSource.camera);
    if (image == null) return;
    var file = await ImageUtil.cropImage(image.path, square: true);
    if (file == null) return;
    _setImage(file);
  }

  Future<void> _getImageFromGallery() async {
    var image = await ImageUtil.pickImage(context, ImageSource.gallery);
    if (image == null) return;
    var file = await ImageUtil.cropImage(image.path, square: true);
    if (file == null) return;
    _setImage(file);
  }

  void _setImage(File croppedFile) async {
    File resizedFile;
    try {
      resizedFile = await ImageUtil.shrinkIfNeeded(
          croppedFile, Consts.PROFILE_IMAGE_WIDTH);

      setState(() {
        _updateProfileImage = croppedFile; // 先に画面に反映させてしまう
        _isImageUploading = true;
      });

      final encodedDataImage = ImageUtil.toBase64DataImage(resizedFile);

      final userModel = Provider.of<UserModel>(context, listen: false);
      final service = BackendService(context);

      final response = await service.putUserThumb(encodedDataImage);

      setState(() {
        _isImageUploading = false;
      });
      if (response != null && response.result == true) {
        // キャッシュを削除
        await ImageUtil.evictImage(
            BackendService.getUserThumbnailUrl(userModel.id));
        await ImageUtil.evictImage(
            BackendService.getUserThumbnailUrl(userModel.id, small: true));
      } else {
        // 送信に失敗したので、プロフィール画像を元に戻す
        setState(() {
          _updateProfileImage = null;
        });

        // TODO: エラー表示
      }
    } finally {
      if (resizedFile != null && resizedFile != croppedFile)
        await resizedFile.delete();
      if (croppedFile != null) await croppedFile.delete();
    }
  }

  Future<void> showSelectDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  _getImageFromCamera();
                },
                child: Text('カメラ'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  _getImageFromGallery();
                },
                child: Text('ギャラリー'),
              )
            ],
          );
        });
  }
  // --------- プロフィール画像変更 ---------

  // プロフィールを編集
  Future<void> _editProfilePage(UserModel userModel) async {
    await Navigator.push(
      context,
      FadeRoute(
        builder: (context) => ProfileEditPage(
          message: userModel?.profile ?? '',
          onUpdated: (profile) {
            setState(() {
              userModel.setProfile(profile);
              userModel.saveToStorage();
            });
          },
        ),
      ),
    );
  }

  Future<void> _startRequest() async {
    if (!_isLoading) {
      setState(() => _isLoading = true);
      await _requestMyInfo();
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestMyInfo() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final response = await OnMemoryCache.fetch(
        ApiPath.mypage, Duration(minutes: 1), () async {
      final service = BackendService(context);
      final response = await service.getMypage();
      return response?.result == true ? response : null;
    }, force: true);
    Provider.of<BadgeInfo>(context, listen: false)
        .applyMyPageResponse(response);
    if (response?.result == true) {
      final data = response.data;
      final service = BackendService(context);
      final responseBadge = await service.getIconBadge(data.getByKey('id'));

      setState(() {
        listIcon = responseBadge?.result == true ? getListIconBadge(responseBadge.data.getByKey('badge')) : [];
        showAllBadge = listIcon.length > 8 ?  false : true;
        _followerCount = data.getByKey('follower_count');
        _monthlyRanking = data.getByKey('rank');

        int benefit;
        dynamic benefitValue = data.getByKey('benefit');
        if (benefitValue is String)
          benefit = int.tryParse(benefitValue);
        else if (benefitValue is int) benefit = benefitValue;
        _benefit = benefit;

        userModel.setPoint(data.getByKey('point'));
        userModel.setMonthlyGiftPoint(data.getByKey('monthly_gift_point'));
        userModel.setMonthlyLiveTime(data.getByKey('monthly_live_time'));
        userModel.setIAPRecovery(data.getByKey('iap_recovery'));
        userModel.setBeginner(response);
        userModel.setEnableEvent(data);
        userModel.saveToStorage();
      });
    }
  }
}
