import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/timeline/timeline_post_model.dart';
import 'package:live812/domain/model/user/other_user.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/usecase/timeline_usecase.dart';
import 'package:live812/ui/item/GridPeopleItem.dart';
import 'package:live812/ui/item/TimelineItem.dart';
import 'package:live812/ui/scenes/timeline/timeline_comment_manager.dart';
import 'package:live812/ui/scenes/timeline/timeline_post_form.dart';
import 'package:live812/ui/scenes/user/profile_view.dart';
import 'package:live812/utils/keyboard_util.dart';
import 'package:live812/utils/timeline_post_manager.dart';
import 'package:live812/utils/widget/spinning_indicator.dart';
import 'package:provider/provider.dart';

class TimelinePage extends StatefulWidget {
  final String userId;
  final void Function(Function) onSetUp;
  final void Function(bool) setHideBroadcastButton;

  TimelinePage({Key key, this.userId, this.onSetUp, this.setHideBroadcastButton})
      : super(key: key);

  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage>
    with AutomaticKeepAliveClientMixin<TimelinePage> {
  ScrollController _scrollController;
  bool _isLiver;
  final _postMan = TimelinePostManager();
  final _commentManager = TimelineCommentManager();
  TimelinePostModel _editingPost;
  final _messageEditingController = TextEditingController();
  bool _noFollow;  // フォローしているライバーはいない？
  bool _showRecommendation;
  List<dynamic> _recommendationList;
  String _noTimelineMessage = '';

  bool _isLoading = false;
  bool _noNext = false;          // タイムライン：次はなし？
  bool _nextRequesting = false;  // タイムライン：次の読み込み中？

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _messageEditingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    //_scrollController.addListener(_appendItems);

    {
      final userModel = Provider.of<UserModel>(context, listen: false);
      _isLiver = userModel.isLiver == true;
      _noFollow = userModel.followCsv?.isNotEmpty != true;
    }
    _showRecommendation = false;

    if (widget.onSetUp != null) {
      widget.onSetUp(() {
        if (!mounted)
          return;

        setState(() {
          _editingPost = null;
          _messageEditingController.clear();
        });

        // フォロー状態が変わったかどうか調べる
        final userModel = Provider.of<UserModel>(context, listen: false);
        bool noFollow = userModel.followCsv?.isNotEmpty != true;
        if (noFollow != _noFollow) {
          setState(() {
            _noFollow = noFollow;
            _showRecommendation = _noFollow;
          });

          if (_showRecommendation) {
            _requestRecommendation();
          }
        }

        if (!_showRecommendation) {
          if (_scrollController.hasClients)
            _scrollController.jumpTo(0);
          _requestTimeline(true);
        }

        _setHideBroadcastButton(_commentManager.isAnyOpen());
      });
    }

    _detectContent();
  }

  Future<void> _detectContent() async {
    _showRecommendation = false;

    // フォロワーがなく、自分の投稿がない場合にはおすすめ表示
    if (!_isLiver && _noFollow) {
      // ライバーじゃなければ自分の投稿はないので、おすすめ表示
      _showRecommendation = true;
    }

    if (_showRecommendation) {
      await _requestRecommendation();
    } else {
      await _requestTimeline(true);
    }
  }

  void _setHideBroadcastButton(bool value) {
    if (widget.setHideBroadcastButton != null)
      widget.setHideBroadcastButton(value);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        !_isLiver ? Container() : TimelinePostForm(
          timelineId: _editingPost?.id,
          editingController: _messageEditingController,
          imgUrl: _editingPost?.imgUrl,
          beforePost: () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeOutQuad);
            }
          },
          onPost: (_text, _imageFile, _date) async {
            final edited = _editingPost;
            setState(() {
              _showRecommendation = false;
              _editingPost = null;
              _messageEditingController.clear();
            });
            if (edited == null) {
              await _requestTimeline(true);
            } else {
              // 編集された内容を取得するため、インデクスを計算
              final index = _postMan.posts.indexWhere((post) => post.id == edited.id);
              if (index >= 0) {
                await _requestTimeline(false, offset: index);
              } else {
                _postMan.clear();
                await _requestTimeline(true);
              }
            }
          },
          onCancel: _editingPost == null ? null : () {
            setState(() {
              _editingPost = null;
            });
          },
        ),
        Expanded(
          child: _showRecommendation ? _buildRecommendationView() : _buildTimelineContent(),
        ),
      ],
    );
  }

  Widget _buildTimelineContent() {
    return Stack(
      children: [
        _buildTimelineView(),
        !_isLoading ? null : SpinningIndicator(shade: false),
      ].where((w) => w != null).toList(),
    );
  }

  Widget _buildTimelineView() {
    if (_postMan.isNull || _postMan.isEmpty) {
      return Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            itemBuilder: (context, _) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 120.0),
                  child: Text(
                    _postMan.isNull ? _noTimelineMessage : 'まだ投稿はありません',
                    style: TextStyle(color: _postMan.isNull ? Colors.grey : Colors.white),
                  ),
                ),
              );
            },
            itemCount: 1,
          ),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!_nextRequesting && scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadNextPage();
              });
            }
            return true;
          },
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                //padding: EdgeInsets.only(top: 0),
                itemBuilder: (context, index) {
                  final post = _postMan.posts[index];
                  return GestureDetector(
                    onTap: () {
                      KeyboardUtil.close(context);
                      if (_commentManager.closeAllComments()) {
                        setState(() {});
                        _setHideBroadcastButton(false);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: TimelineItem(
                      setHideBroadcastButton: widget.setHideBroadcastButton,
                      post: post,
                      comments: !_commentManager.isOpen(post.id) ? null : _commentManager.getCommentsFor(post.id),
                      thumbnailToProfile: true,
                      isEditing: _editingPost?.id == post.id,
                      onToggleComment: () {
                        if (_commentManager.isOpen(post.id)) {
                          KeyboardUtil.close(context);

                          setState(() {
                            _commentManager.closeComment(post.id);
                          });
                          _setHideBroadcastButton(false);
                        } else {
                          _commentManager.openComment(post.id);
                          _requestComment(post);
                        }
                      },
                      onPostComment: (_comment) {
                        _requestComment(post);
                      },
                      onChangeLike: (like) {
                        _changeLike(post, like);
                      },
                      deleteCallback: () async {
                        if (await _confirmDelete()) {
                          await _deleteItem(index);
                          setState(() {
                            _editingPost = null;
                            _messageEditingController.clear();
                          });
                        }
                      },
                      editCallback: () {
                        setState(() {
                          _editingPost = post;
                          _messageEditingController.text = post.msg;
                        });
                      },
                    ),
                  );
                },
                itemCount: _postMan.posts.length,
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _loadNextPage() async {
    if (_nextRequesting || _noNext)
      return;

    setState(() => _nextRequesting = true);
    await _requestTimeline(false);
    setState(() => _nextRequesting = false);
  }

  Widget _buildRecommendationView() {
    if (_recommendationList == null) {
      return SpinningIndicator();
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "フォローしてみよう",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                "assets/svg/electric.svg",
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "おすすめのライバー",
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: .68,
            padding: EdgeInsets.only(
              top: 0,
              bottom: MediaQuery.of(context).padding.bottom + (_isLiver ? 40 : 0),
            ),
            children: List.generate(
              _recommendationList.length,
              (index) {
                final data = OtherUserModel.fromJson(_recommendationList[index]);
                return GridPeopleItem(
                  userId: data.id,
                  nickname: data.nickname,
                  isFollowing: _isFollowingUser(data),
                  onClickUser: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileViewPage(
                          userId: data.id,
                        ),
                      ),
                    );
                  },
                  onFollowChanged: (followed) async {
                    if (followed) {
                      await _requestTimeline(true);
                    }
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  bool _isFollowingUser(OtherUserModel json) {
    return json.followed;
  }

  Future<void> _onRefresh() async {
    if (await _requestTimeline(true)) {
      // コメント更新
      final futures = _commentManager.requestOpenedComments(context);
      if (futures != null) {
        final results = await Future.wait(futures.toList());
        bool updated = false;
        results.forEach((tuple) {
          final comments = tuple?.item2;
          if (comments != null) {
            final post = _postMan.posts.firstWhere((post) => post.id == tuple.item1);
            if (post != null && post.commentCount != comments.length) {
              post.setCommentCount(comments.length);
              updated = true;
            }
          }
        });
        if (updated) {
          setState(() {}); // なにかしら更新があったら画面に反映させる
        }
      }
    }
  }

  Future<bool> _requestTimeline(bool refresh, {int offset}) async {
    if (_isLoading)
      return false;

    setState(() => _isLoading = true);
    if (!refresh) {
      if (offset == null)
        offset = _postMan.posts.length;
    } else {
      offset = null;
    }
    final result = await TimelineUsecase.requestTimeline(context, userId: widget.userId, offset: offset);
    _setStateSafe(() => _isLoading = false);

    if (!mounted)
      return false;

    return result.match(
      ok: (list) {
        _setStateSafe(() => _postMan.setPosts(list, refresh));
        if (refresh) {
          _noNext = false;
          if (list.isNotEmpty) {
            setState(() => _showRecommendation = false);
          } else {
            setState(() => _showRecommendation = true);
            _requestRecommendation();
          }
        } else {
          if (list.isEmpty)
            _noNext = true;
        }
        return true;
      },
      err: (msg) {
        setState(() {
          _noTimelineMessage = msg ?? 'データの取得に失敗しました';
        });
        return false;
      },
    );
  }

  Future<bool> _requestComment(TimelinePostModel post) async {
    final comments = await _commentManager.requestFor(context, post.id);
    if (comments == null)
      return false;

    setState(() {
      // ポストのコメント数を更新してやる
      post.setCommentCount(comments.length);
    });
    return true;
  }

  Future<bool> _requestRecommendation() async {
    final userId = Provider.of<UserModel>(context, listen: false).id;
    final service = BackendService(context);
    setState(() => _isLoading = true);
    final response = await service.getRecommendation(userId);
    setState(() => _isLoading = false);
    if (response?.result != true || !mounted)
      return false;

    setState(() {
      _recommendationList = response.getData();
    });
    return true;
  }

  Future<bool> _confirmDelete() async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('削除'),
          content: Text('投稿を削除しますか？削除した投稿は取り消しできません。'),
          actions: [
            FlatButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FlatButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) == true;
  }

  Future<void> _deleteItem(int index) async {
    final _ = await BackendService(context).deleteTimeline(_postMan.posts[index].id);
    setState(() {
      _postMan.removePostAt(index);
    });

    if (_postMan.isEmpty) {
      // 投稿がなくなったらおすすめ表示に戻す
      setState(() => _showRecommendation = true);
      await _requestRecommendation();
    }
  }

  void _changeLike(TimelinePostModel post, bool like) {
    if (post.liked == like)
      return;
    setState(() {
      post.setLike(like);
    });
  }

  void _setStateSafe(void Function() func) {
    // dispose された後に setState を呼び出すとエラーが出るので、状態によって切り替える
    if (mounted) {
      setState(func);
    } else {
      func();
    }
  }
}
