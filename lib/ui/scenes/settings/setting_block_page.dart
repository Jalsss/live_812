import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/other_user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/profile_dialog.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';

class SettingBlockPage extends StatefulWidget {
  @override
  SettingBlockPageState createState() => SettingBlockPageState();
}

class SettingBlockPageState extends State<SettingBlockPage> {
  Future<List<OtherUserModel>> _blockedUsers;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _update();
  }

  void _update() {
    _blockedUsers = _getBlockedUsers();
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      isLoading: _isLoading,
      backgroundColor: ColorLive.MAIN_BG,
      title: Lang.BLOCK,
      titleColor: Colors.white,
      body: FutureBuilder(
        future: _blockedUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final blockedUsers = snapshot.data as List<OtherUserModel>;
            if (blockedUsers == null || blockedUsers.length == 0) {
              return Container(
                child: Center(
                  child: Text(
                    'ブロック中のユーザーはいません',
                    style: TextStyle(color: ColorLive.TRANS_WHITE_90),
                  ),
                ),
              );
            } else {
              return ListView(
                padding: EdgeInsets.only(top: 0),
                children: List.generate(blockedUsers.length, (index) {
                  return _buildBlockingUser(
                    blockedUsers[index],
                  );
                }),
              );
            }
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget _buildBlockingUser(OtherUserModel target) {
    final blocking = target.blocked;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 9),
      child: Row(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => ProfileDialog(userId: target.id),
                );
              },
              child: Row(
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white),
                      image: target.imgSmallUrl == null ? null : DecorationImage(
                        image: NetworkImage(target.imgSmallUrl),
                        fit: BoxFit.cover,
                      ),
                      color: target.imgSmallUrl != null ? null : Color(0xff404040),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          target.nickname ?? "-",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          target.symbol ?? "-",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              border: Border.all(color: ColorLive.BORDER2, width: 1),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                colors: [
                  blocking ? ColorLive.BORDER2 : ColorLive.BLUE,
                  blocking ? ColorLive.BORDER2 : ColorLive.BLUE_GR
                ],
              ),
            ),
            child: FlatButton(
              textColor: Colors.white,
              onPressed: () {
                _postBlockUser(target, !blocking);
              },
              child: Text(
                !blocking ? Lang.BLOCK : Lang.RELEASE_BLOCK,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<OtherUserModel>> _getBlockedUsers() async {
    final service = BackendService(context);
    setState(() => _isLoading = true);
    final response = await service.getBlockListener();
    setState(() => _isLoading = false);
    if (response?.result != true)
      return null;
    final data = response.getData() as List;
    return data.map((info) {
      final user = OtherUserModel.fromJson(info);
      if (user.blocked == null) {  // getBlockListener のレスポンスにis_blockが含まれていないので、デフォルト=trueとする
        user.setBlocked(true);
      }
      return user;
    }).toList();
  }

  Future<void> _postBlockUser(OtherUserModel target, bool newBlocking) async {
    final service = BackendService(context);
    setState(() => _isLoading = true);
    final response = await service.postBlockListener(target.id, newBlocking);
    setState(() => _isLoading = false);
    if (response?.result != true)
      return null;
    setState(() => target.setBlocked(newBlocking));
  }
}
