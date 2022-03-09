import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live812/domain/model/user/other_user.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/scenes/user/model/icon_badge_model.dart';
import 'package:live812/ui/scenes/user/widget/list_icon_badge_widget.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/super_text_util.dart';
import 'package:live812/utils/widget/spinning_indicator.dart';
import 'package:provider/provider.dart';

class ProfileDialog extends StatefulWidget {
  final String userId;

  ProfileDialog({Key key, @required this.userId}) : super(key: key);

  @override
  _ProfileDialogState createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  OtherUserModel _targetUser;
  var _blocked = false;
  var _isBlockEnable = false;
  var _isSelf = false;

  bool showAllBadge = false;

  List<IconBadge> listIcon = [];

  @override
  void initState() {
    super.initState();

    // 自分がライバーで、対象が自分じゃない場合にのみブロック可能
    final userModel = Provider.of<UserModel>(context, listen: false);
    _isBlockEnable = userModel.isLiver && widget.userId != userModel.id;
    _isSelf = userModel.id == widget.userId;

    _requestUser();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      child: _dialogContent(context),
    );
  }

  Widget _dialogContent(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? MediaQuery.of(context).size.height - 200
          : MediaQuery.of(context).size.height - 100,
      padding: const EdgeInsets.only(
        left: Consts.padding,
        top: Consts.padding,
        right: Consts.padding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: _targetUser == null
                ? Center(child: SpinningIndicator(shade: false))
                : ListView(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(width: 44), // 左右合わせ用
                          Expanded(
                            child: Center(
                              child: SizedBox(
                                width: 140,
                                height: 140,
                                child: CircleAvatar(
                                  radius: 15.0,
                                  backgroundImage:
                                      NetworkImage(_targetUser.imgThumbUrl),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 44,
                            child: !_isBlockEnable
                                ? null
                                : Column(
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          _openBottomSheet(context);
                                        },
                                        child: const SizedBox(
                                          width: double.infinity,
                                          height: 44,
                                          child: Icon(
                                            Icons.more_horiz,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _targetUser.nickname ?? '',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            _targetUser.symbol ?? '',
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          IconButton(
                            icon: const Icon(Icons.content_copy),
                            color: Colors.grey,
                            onPressed: () async {
                              final data =
                                  ClipboardData(text: _targetUser.symbol ?? '');
                              await Clipboard.setData(data);
                              Flushbar(
                                icon: Icon(
                                  Icons.info_outline,
                                  size: 28.0,
                                  color: Colors.blue[300],
                                ),
                                message: Lang.COPIED,
                                duration: const Duration(milliseconds: 2000),
                                margin: const EdgeInsets.all(8),
                                borderRadius: 8,
                              )..show(context);
                            },
                          ),
                        ],
                      ),
                      listIcon.length > 0
                          ? ListIconBadge(
                              listIconBadge: listIcon,
                              showAllBadge: showAllBadge,
                              showAll: () {
                                setState(() {
                                  showAllBadge = !showAllBadge;
                                });
                              },
                              colorsDropdown: Colors.black,
                            )
                          : SizedBox(),
                      _buildProfile(context, _targetUser.profile),
                    ],
                  ),
          ),
          (_targetUser?.isLiver ?? false) && (!_isSelf)
              ? Container(
                  width: double.infinity,
                  child: Container(
                    height: 34,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(17)),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        colors: [ColorLive.BLUE, ColorLive.BLUE_GR],
                      ),
                    ),
                    child: FlatButton(
                      textColor: Colors.white,
                      onPressed: () async {
                        await _requestFollow(context);
                      },
                      child: Text(
                        _targetUser?.followed ?? false
                            ? Lang.FOLLOWING
                            : Lang.FOLLOWING1,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                )
              : Container(),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildProfile(BuildContext context, String profile) {
    if (profile?.isNotEmpty != true) {
      return Text("-", textAlign: TextAlign.center);
    }

    final list = SuperTextUtil.parse(profile + '\n');

    return SuperTextWidget(
      list,
      textStyle: const TextStyle(color: Colors.black),
      external: true,
      textAlign: TextAlign.center,
    );
  }

  Future<void> _openBottomSheet(BuildContext context) async {
    const BLOCK = 1;
    final result = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10 + MediaQuery.of(context).padding.bottom,
              left: 15,
              right: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(5),
                topRight: const Radius.circular(5),
              ),
            ),
            child: Column(
              children: <Widget>[
                _buildBlockButton(
                  _blocked ? Lang.RELEASE_BLOCK : Lang.BLOCK,
                  onTap: () {
                    Navigator.pop(context, BLOCK);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    switch (result) {
      case BLOCK:
        _requestBlock(context);
        break;
      default:
        break;
    }
  }

  Widget _buildBlockButton(String text, {@required void Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          color: Color(0xff404040),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> _requestUser() async {
    final service = BackendService(context);
    final response = await service.getUser(widget.userId);
    if (response?.result != true) {
      return;
    }
    final responseBadge = await service.getIconBadge(widget.userId);

    setState(() {
      showAllBadge = listIcon.length > 8 ? false : true;
      listIcon = responseBadge?.result == true
          ? getListIconBadge(responseBadge.data.getByKey('badge'))
          : [];
      _targetUser = OtherUserModel.fromJson(response.getData());
      _blocked = _targetUser.blocked;
      if (_targetUser.blocked == null) _targetUser.setBlocked(_blocked = false);
    });
  }

  Future<void> _requestBlock(BuildContext context) async {
    var newBlocked = !_blocked;
    final service = BackendService(context);
    final response = await service.postBlockListener(widget.userId, newBlocked);
    if (response?.result == true) {
      setState(() {
        _blocked = newBlocked;
        if (_blocked) {
          // ブロックしたのでダイアログを閉じる
          Navigator.pop(context);
        }
      });
    }
  }

  Future<void> _requestFollow(BuildContext context) async {
    final service = BackendService(context);

    final followId = _targetUser.followed ? null : _targetUser.id;
    final unFollowId = _targetUser.followed ? _targetUser.id : null;
    final response = await service.postUserFollow(
      followId: followId,
      unfollowId: unFollowId,
    );
    if (response?.result == true) {
      // フォローしたのでダイアログを閉じる.
      Navigator.pop(context);
    }
  }
}
