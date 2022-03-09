import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:live812/domain/model/timeline/timeline_comment_model.dart';
import 'package:live812/domain/model/timeline/timeline_post_model.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/ui/scenes/user/profile_view.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/counter_textfield.dart';
import 'package:live812/utils/widget/spinning_indicator.dart';
import 'package:live812/ui/dialog/profile_dialog.dart';
import 'package:provider/provider.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:flutter/cupertino.dart';

enum _TimelineAction { edit, delete }

class TimelineItem extends StatefulWidget {
  final TimelinePostModel post;
  final List<TimelineCommentModel> comments;
  final bool thumbnailToProfile;  // サムネイルタップでプロフィールを見る？
  final void Function() onToggleComment;
  final void Function(String) onPostComment;
  final void Function(bool) onChangeLike;
  final void Function() editCallback;
  final Future<void> Function() deleteCallback;
  final void Function(bool) setHideBroadcastButton;
  final bool isEditing;

  TimelineItem({
    @required this.post,
    @required this.comments,
    this.thumbnailToProfile = false,
    @required this.onToggleComment,
    this.onPostComment,
    @required this.onChangeLike,
    this.editCallback,
    this.deleteCallback,
    this.setHideBroadcastButton,
    this.isEditing = false,
  })
      : super(key: Key(post.id));

  @override
  _TimelineItemState createState() => _TimelineItemState();
}

class _TimelineItemState extends State<TimelineItem> {
  final _commentController = TextEditingController();
  FocusNode _focusNode;

  var _commentPage = 0;
  var _isPostingComment = false;
  var _isPostingLike = false;
  Timer _postingLikeTimer;

  bool get _isLiked => widget.post.liked == true;

  @override
  void dispose() {
    _focusNode.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      _setHideBroadcastButton(_focusNode.hasFocus);
    });
  }

  void _setHideBroadcastButton(bool value) {
    if (widget.setHideBroadcastButton != null)
      widget.setHideBroadcastButton(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: !widget.isEditing ? null : Color(0x8080e0ff),
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: <Widget>[
              !_isEditable()
                  ? _buildPost()
                  : InkWell(
                      onTap: () {}, // Rippleエフェクトを表示するにはこれが必要
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onLongPress: () async {
                          await _confirmEdit();
                        },
                        child: _buildPost(),
                      ),
                    ),
              _buildLikeCommentCountRow(),
              widget.comments == null ? Container() : Stack(
                children: [
                  Column(
                    children: [
                      _buildComments(widget.comments),
                      _buildCommentInputBox(),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(
          color: ColorLive.DIVIDER,
          height: 0,
          thickness: 0.2,
        ),
      ],
    );
  }

  bool _isEditable() {
    if (widget.editCallback == null && widget.deleteCallback == null)
      return false;

    final userId = Provider.of<UserModel>(context, listen: false).id;
    return widget.post.accountId == userId;
  }

  bool _isSelfPost() {
    final userId = Provider.of<UserModel>(context, listen: false).id;
    return widget.post.accountId == userId;
  }

  // 投稿表示
  Widget _buildPost() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 30,
              height: 30,
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
              child: RawMaterialButton(
                elevation: 2,
                shape: CircleBorder(),
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage: NetworkImage(
                      BackendService.getUserThumbnailUrl(widget.post.accountId)),
                  onBackgroundImageError: (d, s) {},
                  backgroundColor: Colors.transparent,
                ),
                onPressed: !widget.thumbnailToProfile || _isSelfPost() ? null : () async {
                  final _ = await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProfileViewPage(userId: widget.post.accountId)));
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.post.nickname,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8),
            Text(
              DateFormat('yyyy.MM.dd HH:mm').format(widget.post.createDate),
              style: TextStyle(
                  color: Colors.grey, fontSize: 12, fontFamily: "Roboto"),
            )
          ],
        ),
        widget.post.imgUrl == null ? null : Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: FadeInImage.assetNetwork(
            image: widget.post.imgUrl,
            fit: BoxFit.fitWidth,
            placeholder: "assets/images/placeholder.png",
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.post.msg,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ].where((w) => w != null).toList(),
    );
  }

  // いいね、コメント数の行
  Widget _buildLikeCommentCountRow() {
    return Row(
      children: <Widget>[
        MaterialButton(
          minWidth: 50,
          onPressed: _isPostingLike || _postingLikeTimer != null ? null : _requestToggleLike,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            children: <Widget>[
              SvgPicture.asset(
                "assets/svg/tl_heart.svg",
                color: _isLiked ? Colors.pink : Colors.white,
              ),
              SizedBox(width: 5),
              Text(
                widget.post.likeCount.toString(),
                style: TextStyle(
                    color: _isLiked ? Colors.pink : Colors.white,
                    fontSize: 16,
                    fontFamily: "Roboto"),
              )
            ],
          ),
        ),
        SizedBox(width: 5),
        MaterialButton(
          minWidth: 50,
          onPressed: () {
            _commentController.clear();
            widget.onToggleComment();
          },
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            children: <Widget>[
              SvgPicture.asset(
                "assets/svg/tl_chat.svg",
                color: widget.comments != null ? Colors.blue : Colors.white,
              ),
              SizedBox(width: 5),
              Text(
                "${widget.comments?.length ?? widget.post.commentCount ?? '-'}",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: "Roboto"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // コメント
  Widget _buildComments(List<TimelineCommentModel> comments) {
    if (comments == null)
      return Container();

    return Stack(
      children: [
        comments.length > 0
            ? Icon(
                Icons.subdirectory_arrow_right,
                size: 24.0,
                color: ColorLive.BLUE,
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Column(
            children: <Widget>[
              Column(
                children: comments
                    .sublist(
                        0,
                        3 * (_commentPage + 1) > comments.length
                            ? comments.length
                            : 3 * (_commentPage + 1))
                    .map((comment) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: 30,
                            height: 30,
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white),
                            child: RawMaterialButton(
                              elevation: 2,
                              shape: CircleBorder(),
                              child: CircleAvatar(
                                radius: 50.0,
                                backgroundImage: NetworkImage(
                                    BackendService.getUserThumbnailUrl(
                                        comment.accountId)),
                                backgroundColor: Colors.transparent,
                              ),
                              onPressed: () {
                                final userId = Provider.of<UserModel>(context, listen: false).id;
                                if (comment.accountId == userId)
                                  return;

                                if (comment.isLiver) {
                                  Navigator.push(
                                      context,
                                      FadeRoute(builder: (context) => ProfileViewPage(userId: comment.accountId)));
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => ProfileDialog(userId: comment.accountId),
                                  );
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              comment.nickname,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            DateFormat('yyyy.MM.dd HH:mm').format(comment.createDate),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontFamily: "Roboto"),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          comment.msg,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Divider(
                        color: ColorLive.DIVIDER,
                        height: 0,
                        thickness: 0.2,
                      ),
                    ],
                  );
                }).toList(),
              ),
              3 * (_commentPage + 1) >= comments.length ? Container() : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => ++_commentPage),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      Lang.MORE,
                      style: TextStyle(color: ColorLive.BLUE),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // コメント入力欄
  Widget _buildCommentInputBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              CounterTextField(
                controller: _commentController,
                hintText: Lang.HINT_TIMELINE_COMMENT,
                count: 30,
                focusNode: _focusNode,
                maxLine: 1,
              ),
              !_isPostingComment ? Container() : SpinningIndicator(),
            ],
          ),
        ),
        Container(
          width: 64.0,
          height: 64.0,
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.all(Radius.circular(5)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              //end: Alignment.centerRight,s
              colors: [
                ColorLive.BLUE,
                ColorLive.BLUE_GR
              ],
              //colors: [Color(0xFF2C7BE5), const Color(0xFF2C7BE5)],
            ),
          ),
          child: FlatButton(
            textColor: Colors.white,
            onPressed: () => _postComment(
                _commentController.text),
            child: Text(
              Lang.REPLY,
              softWrap: false,
            ),
          ),
        ),
      ],
    );
  }

  // 編集 or 削除
  Future<void> _confirmEdit() async {
    // Only the writer of this item can edit a timeline.
    if (!_isSelfPost())
      return;

    final result = await showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            message: Text(Lang.EDIT_TIMELINE),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text(Lang.DO_EDIT),
                onPressed: () {
                  Navigator.of(context).pop(_TimelineAction.edit);
                },
              ),
              CupertinoActionSheetAction(
                child: Text(Lang.DELETE),
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop(_TimelineAction.delete);
                },
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text(Lang.CANCEL),
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          );
        });
    if (result == _TimelineAction.edit) {
      if (widget.editCallback != null) {
        widget.editCallback();
      }
    } else if (result == _TimelineAction.delete) {
      if (widget.deleteCallback != null) {
        await widget.deleteCallback();
      }
    }
  }

  // コメント送信
  Future<void> _postComment(String comment) async {
    if (comment == null || comment.length <= 0)
      return;

    final data = widget.post;

    setState(() {
      _isPostingComment = true;
    });
    final response =
        await BackendService(context).postTimelineMessage(data.id, comment);
    setState(() {
      _isPostingComment = false;
    });
    if (response?.result == true) {
      setState(() {
        _commentController.clear();
        _commentPage = 0;
        _focusNode.unfocus();
        if (widget.onPostComment != null)
          widget.onPostComment(comment);
      });
    } else {
      showNetworkErrorDialog(context, msg: response.getByKey('msg'));
    }
  }

  // いいね！をトグル
  Future<void> _requestToggleLike() async {
    final newLiked = !_isLiked;
    final data = widget.post;
    setState(() {
      _isPostingLike = true;
      _postingLikeTimer = Timer(Duration(milliseconds: 300), () {
        setState(() => _postingLikeTimer = null);
      });
    });
    final response = await BackendService(context).postTimelineLike(data.id, newLiked);
    setState(() => _isPostingLike = false);
    if (response?.result == true) {
      // 自分の状態を更新するため、setStateは必要
      setState(() {
        if (widget.onChangeLike != null)
          widget.onChangeLike(newLiked);
      });
    }
  }
}
