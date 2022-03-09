import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/safe_network_image.dart';
import 'package:provider/provider.dart';

class GridPeopleItem extends StatelessWidget {
  final String userId;
  final String nickname;
  final bool isFollowing;
  final void Function() onClickUser;
  final void Function(bool followed) onFollowChanged;

  GridPeopleItem({
    this.userId,
    this.nickname,
    this.isFollowing,
    this.onClickUser,
    this.onFollowChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Center(
        child: Container(
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  onClickUser();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 3 - 15,
                  height: MediaQuery.of(context).size.width / 3 - 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white),
                    image: DecorationImage(
                      image: SafeNetworkImage(
                          BackendService.getUserThumbnailUrl(userId)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Text(
                nickname,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 2),
              _PeopleFollowButton(
                callback: (bool followed) => _requestFollow(context, followed),
                isFollowing: isFollowing,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestFollow(BuildContext context, bool followed) async {
    final service = BackendService(context);
    bool success = false;
    if (followed) {
      final response = await service.postUserFollow(followId: userId);
      success = response?.result == true;
    } else {
      final response = await service.postUserFollow(unfollowId: userId);
      success = response?.result == true;
    }

    if (success) {
      final userModel = Provider.of<UserModel>(context, listen: false);
      if (followed)
        userModel.addFollow(userId);
      else
        userModel.removeFollow(userId);
      if (onFollowChanged != null)
        onFollowChanged(followed);
    }
  }
}

class _PeopleFollowButton extends StatefulWidget {
  final Future<void> Function(bool didFollow) callback;
  final bool isFollowing;

  _PeopleFollowButton({Key key, @required this.callback, @required this.isFollowing})
      : super(key: key);

  @override
  _PeopleFollowButtonState createState() => _PeopleFollowButtonState();
}

class _PeopleFollowButtonState extends State<_PeopleFollowButton> {
  bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.isFollowing;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() => _isFollowing = !_isFollowing);
        widget.callback(_isFollowing);
      },
      child: _isFollowing
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  color: ColorLive.BLUE_BG,
                  borderRadius: BorderRadius.circular(3)),
              child: Text(Lang.FOLLOWING),
            )
          : Container(
              width: 85,
              padding: EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                  color: Colors.orange, borderRadius: BorderRadius.circular(4)),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 5),
                  Text(Lang.FOLLOW,
                      style: TextStyle(color: Colors.white, fontSize: 12))
                ],
              ),
            ),
    );
  }
}
