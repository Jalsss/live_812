import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/other_user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/item/FollowerItem.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';

class FollowerPage extends StatefulWidget {
  final String userId;

  FollowerPage({@required this.userId});

  @override
  FollowerPageState createState() => FollowerPageState();
}

class FollowerPageState extends State<FollowerPage> {
  Future<List<OtherUserModel>> _followers;

  bool _isLoading = true;
  bool _isUp = true;

  @override
  void initState() {
    super.initState();
    _followers = _getUserFollowersResponse();
  }

  void _update() {
    _followers = _getUserFollowersResponse();
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      isLoading: _isLoading,
      backgroundColor: ColorLive.MAIN_BG,
      title: Lang.FOLLOWER,
      titleColor: Colors.white,
      actions: [
        Container(
          height: 50,
          padding: EdgeInsets.all(0),
          child: Center(
            child: GestureDetector(
              child: Row(
                children: [
                  Text(
                    '登録日時',
                    style: TextStyle(color: ColorLive.TAB_SELECT_BG, fontSize:  14.5),
                  ),
                  Icon(
                    _isUp ? Icons.arrow_drop_down_sharp : Icons.arrow_drop_up_sharp,
                    color: ColorLive.TAB_SELECT_BG,
                    size: 30,
                  )
                ],
              ),
              onTap: () async {
                if(_isUp){
                  final followers = await _followers;
                  followers.sort((a,b) =>  a.followDate.compareTo(b.followDate));
                  setState(() {
                    _followers =  Future.value(followers);
                    _isUp = !_isUp;
                  });
                } else {
                  final followers  = await _followers;
                  followers.sort((a,b) =>  b.followDate.compareTo(a.followDate));
                  setState(() {
                    _followers = Future.value(followers);
                    _isUp = !_isUp;
                  });
                }
              },
            ),
          ),
        )
      ],
      body: FutureBuilder(
        future: _followers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final followers = snapshot.data as List<OtherUserModel>;
            if (followers == null || followers.length == 0) {
              return Container(
                child: Center(
                  child: Text(
                    'フォロワーはいません',
                    style: TextStyle(color: ColorLive.TRANS_WHITE_90),
                  ),
                ),
              );
            } else {
              return ListView(
                padding: EdgeInsets.only(top: 0),
                children: List.generate(followers.length, (index) {
                  return FollowerItem(
                    followerUser: followers[index],
                    onBack: () {
                      setState(() {
                        _update();
                      });
                    },
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

  Future<List<OtherUserModel>> _getUserFollowersResponse() async {
    final service = BackendService(context);
    final response = await service.getUserFollower(widget.userId);
    setState(() {
      _isLoading = false;
    });
    if (response != null && response.result) {
      final data = response.getData() as List;
      final followers = data.map((info) => OtherUserModel.fromJson(info)).toList();
      followers.sort((a,b) =>  b.followDate.compareTo(a.followDate));
      return followers;
    }
    return null;
  }
}