import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/following_notify.dart';
import 'package:live812/domain/model/user/other_user.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/following_notify_dialog.dart';
import 'package:live812/ui/item/FollowingItem.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:provider/provider.dart';

class FollowingPage extends StatefulWidget {
  @override
  FollowingPageState createState() => FollowingPageState();
}

class FollowingPageState extends State<FollowingPage> {
  List<OtherUserModel> _followingUsers;

  bool _isLoading = true;
  bool _isDesc = true;

  @override
  void initState() {
    super.initState();
    _requestFollowingUsers();
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      isLoading: _isLoading,
      backgroundColor: ColorLive.MAIN_BG,
      title: Lang.FOLLOWING,
      titleColor: Colors.white,
      actions: <Widget>[
        FlatButton(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'フォロー日',
                style: TextStyle(
                  fontSize: 14.5,
                  color: ColorLive.ORANGE,
                ),
              ),
              Icon(
                _isDesc ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                color: ColorLive.ORANGE,
                size: 30,
              ),
            ],
          ),
          onPressed: () {
            _changeSort();
          },
        ),
      ],
      body: _followingUsers == null
          ? _buildNoFollowing()
          : ListView(
              padding: EdgeInsets.only(top: 0),
              children: _followingUsers.map((user) {
                return FollowingItem(
                  user,
                  key: ValueKey(user.id),
                  onBack: () {
                    _requestFollowingUsers();
                  },
                  changeNotification: () async {
                    var notify = FollowingNotify(
                        live: user.notifyLive,
                        timeline: user.notifyTimeline,
                        ec: user.notifyEC);
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return FollowingNotifyDialog(notify);
                        });
                    return _changeNotification(user, notify);
                  },
                );
              }).toList(),
            ),
    );
  }

  Widget _buildNoFollowing() {
    if (_isLoading) return Container();

    return Container(
      child: const Center(
        child: Text(
          'フォロー中のライバーはいません',
          style: TextStyle(
            color: ColorLive.TRANS_WHITE_90,
          ),
        ),
      ),
    );
  }

  Future<void> _requestFollowingUsers() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final service = BackendService(context);
    setState(() => _isLoading = true);
    final response =
        await service.getUserFollow(userModel.id, userModel.symbol);
    setState(() => _isLoading = false);
    if (response?.result == true) {
      final data = response.getData() as List;
      List<OtherUserModel> list =
          data.map((info) => OtherUserModel.fromJson(info)).toList();
      if (_isDesc) {
        list.sort((a, b) => b.followDate.compareTo(a.followDate));
      } else {
        list.sort((a, b) => a.followDate.compareTo(b.followDate));
      }
      setState(() => _followingUsers = list);
    }
  }

  void _changeSort() {
    _isDesc = !_isDesc;
    if (_isDesc) {
      _followingUsers.sort((a, b) => b.followDate.compareTo(a.followDate));
    } else {
      _followingUsers.sort((a, b) => a.followDate.compareTo(b.followDate));
    }
    setState(() {});
  }

  Future<bool> _changeNotification(
      OtherUserModel follower, FollowingNotify notify) async {
    final response = await BackendService(context).postUserNotification(
        id: follower.id,
        notifyTimeline: notify.timeline,
        notifyLive: notify.live,
        notifyEC: notify.ec);
    if (response?.result == true) {
      follower.setNotify(notify.live, notify.timeline, notify.ec);
    }
    return follower.notify;
  }
}
