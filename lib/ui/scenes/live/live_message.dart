import 'package:flutter/material.dart';
import 'package:live812/domain/model/live/gift_info.dart';
import 'package:live812/domain/model/live/message.dart';
import 'package:live812/domain/model/socket/chat_socket_model.dart';
import 'package:live812/domain/model/socket/gift_socket_model.dart';
import 'package:live812/domain/model/socket/like_socket_model.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/profile_dialog.dart';
import 'package:live812/utils/deco_text_util.dart';
import 'package:live812/utils/ng_filter.dart';
import 'package:live812/utils/widget/safe_network_image.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LiveMessageWidget extends StatefulWidget {
  final IO.Socket socket;
  final List<GiftInfoModel> giftInfoList;
  final bool isLiver;
  final String liveId;

  LiveMessageWidget({
    Key key,
    @required this.socket,
    @required this.giftInfoList,
    this.isLiver = false,
    @required this.liveId,
  }) : super(key: key);

  @override
  _LiveMessageWidgetState createState() => _LiveMessageWidgetState();
}

class _LiveMessageWidgetState extends State<LiveMessageWidget> {
  static const int _MAX_MESSAGE = 50; // 保持する最大メッセージ数
  final ScrollController scrollController = new ScrollController();
  static const TextStyle kSystemTextStyle = TextStyle(
      color: Color.fromRGBO(255, 255, 255, 0.6),
      fontSize: DecoTextUtil.FONT_SIZE);

  List<MessageModel> _messages = [];
  List<MessageModel> _messagesBackup = [];
  bool showButton = false;
  @override
  void initState() {
    super.initState();
    if (widget.socket != null) {
      widget.socket.on('message', _receiveMessage);
      widget.socket.on('like', _receiveLike);
      widget.socket.on('gift', _receiveGift);
      widget.socket.on('sales', _receiveSales);
      widget.socket.on('sold', _receiveSold);
    }
    if (widget.isLiver) {
      _messages.add(MessageModel(
          MessageType.SYSTEM,
          '利用規約に基づくライブ配信を行いましょう。24時間体制でパトロール監視を行っており、露出などの規約違反がある場合は配信停止またはアカウント停止を行う場合があります。',
          null));
    } else {
      _messages.add(
          MessageModel(MessageType.SYSTEM, 'ライバーにメッセージやギフトを送ってみよう！', null));
    }
  }

  @override
  void dispose() {
    if (widget.socket != null) {
      widget.socket.off('message', _receiveMessage);
      widget.socket.off('like', _receiveLike);
      widget.socket.off('gift', _receiveGift);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        NotificationListener(
          onNotification: (notificationInfo) {
            if(notificationInfo is ScrollNotification) {
              if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
                setState(() {
                  _messagesBackup = [];
                  showButton = false;
                });
              }
            }
            return true;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            // reverse: true,
            controller: scrollController,
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _messages.reversed.map((message) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        borderRadius:
                        const BorderRadius.all(Radius.circular(10)),
                        color: const Color(0x000000).withOpacity(0.6)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        message.userId == null
                            ? Container()
                            : Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              shape: BoxShape.circle),
                          margin: const EdgeInsets.only(right: 5),
                          child: RawMaterialButton(
                            elevation: 2,
                            shape: const CircleBorder(),
                            child: CircleAvatar(
                              radius: 15.0,
                              backgroundImage: SafeNetworkImage(
                                  BackendService.getUserThumbnailUrl(
                                      message.userId,
                                      small: true)),
                              onBackgroundImageError: (d, s) {},
                              backgroundColor:
                              Colors.white.withAlpha(100),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => ProfileDialog(
                                    userId: message.userId),
                              );
                            },
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: DecoTextUtil.build(
                              message.decoText,
                              style: message.userId == null
                                  ? kSystemTextStyle
                                  : DecoTextUtil.defaultTextStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        showButton
            ? GestureDetector(
                child: Container(
                  padding: EdgeInsets.all(3),
                  constraints: BoxConstraints(maxWidth: 36, maxHeight: 36, minWidth: 26,minHeight: 26),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle),
                  margin: EdgeInsets.only(left: 80),
                  child: Text(
                    '${_messagesBackup.length > 99 ? '99+' : _messagesBackup.length}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                onTap: () {
                  scrollController.animateTo(scrollController.position.maxScrollExtent,
                      curve: Curves.bounceIn,
                      duration: Duration(milliseconds: 100));
                  setState(() {
                    _messagesBackup = [];
                    showButton = false;
                  });
                },
              )
            : SizedBox()
      ],
    );
  }

  void _receiveMessage(dynamic data) {
    if (_debugIllegalLiveId(data['live_id'])) return;

    if (data['has_ng_word'] == true) {
      NGFilter.showAlertDialog(context);
      return;
    }

    final chat = ChatSocketModel.fromJson(data);
    _addMessage(MessageModel(MessageType.CHAT,
        [HighLight(chat.nickName), ' ${chat.message}'], chat.userId));
    if(scrollController.position.pixels < scrollController.position.maxScrollExtent) {

      _addMessageBackup(MessageModel(MessageType.CHAT,
          [HighLight(chat.nickName), ' ${chat.message}'], chat.userId));
      setState(() {
        showButton = true;
      });
    } else if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      Future.delayed(Duration(milliseconds: 200), () {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            curve: Curves.bounceIn,
            duration: Duration(milliseconds: 100));
      });
    }
  }

  void _receiveLike(dynamic data) {
    if (_debugIllegalLiveId(data['live_id'])) return;

    final like = LikeSocketModel.fromJson(data);
    final userModel = Provider.of<UserModel>(context, listen: false);

    if (_messages.isNotEmpty) {
      // 2回目以降のメッセージは表示しない..が、配信一回抜けると無効になるので注意
      var result = _messages.firstWhere(
          (message) =>
              (message.userId == like.userId) &&
              (message.type == MessageType.LIKE),
          orElse: () => null);
      if (result != null) {
        return;
      }
    }

    if (userModel.id == like.userId) {
      _addMessage(MessageModel(MessageType.LIKE, 'いいね💗を送りました️', like.userId));
    } else {
      _addMessage(
          MessageModel(MessageType.LIKE, [HighLight(like.nickName), 'がいいね💗️'], like.userId));
    }
    if(scrollController.position.pixels < scrollController.position.maxScrollExtent) {
      if (userModel.id == like.userId) {
        _addMessageBackup(MessageModel(MessageType.LIKE, 'いいね💗を送りました️', like.userId));
      } else {
        _addMessageBackup(
            MessageModel(MessageType.LIKE, [HighLight(like.nickName), 'がいいね💗️'], like.userId));
      }
      setState(() {
        showButton = true;
      });
    } else if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      Future.delayed(Duration(milliseconds: 200), () {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            curve: Curves.bounceIn,
            duration: Duration(milliseconds: 100));
      });
    }
  }

  void _receiveGift(dynamic data) {
    if (_debugIllegalLiveId(data['live_id'])) return;

    final gift = GiftSocketModel.fromJson(data);
    final userModel = Provider.of<UserModel>(context, listen: false);
    var giftName = 'ギフト';
    if (widget.giftInfoList != null) {
      final giftInfo = widget.giftInfoList
          .singleWhere((g) => g.id.toString() == gift.id, orElse: () => null);
      if (giftInfo != null) {
        giftName = giftInfo.name;
      }
    }
    if (userModel.id == gift.userId) {
      _addMessage(MessageModel(
          MessageType.GIFT, '$giftName(${gift.point})を贈りました❗️', gift.userId));
    } else {
      _addMessage(MessageModel(
          MessageType.GIFT,
          [HighLight(gift.nickName), 'が$giftName(${gift.point})を贈りました❗️'],
          gift.userId));
    }
    if(scrollController.position.pixels < scrollController.position.maxScrollExtent) {
      if (userModel.id == gift.userId) {
        _addMessageBackup(MessageModel(
            MessageType.GIFT, '$giftName(${gift.point})を贈りました❗️', gift.userId));
      } else {
        _addMessageBackup(MessageModel(
            MessageType.GIFT,
            [HighLight(gift.nickName), 'が$giftName(${gift.point})を贈りました❗️'],
            gift.userId));
      }
      setState(() {
        showButton = true;
      });
    } else if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      Future.delayed(Duration(milliseconds: 200), () {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            curve: Curves.bounceIn,
            duration: Duration(milliseconds: 100));
      });
    }
  }

  void _receiveSales(dynamic data) {
    if (_debugIllegalLiveId(data['live_id'])) return;

    if (widget.isLiver) {
      _addMessage(MessageModel(MessageType.SALES,
          [HighLight('「${data['item_name']}」'), 'を出品しました'], null));
    } else {
      _addMessage(MessageModel(MessageType.SALES,
          [HighLight('「${data['item_name']}」'), 'が出品されました'], null));
    }
    if(scrollController.position.pixels  < scrollController.position.maxScrollExtent) {
      if (widget.isLiver) {
        _addMessageBackup(MessageModel(MessageType.SALES,
            [HighLight('「${data['item_name']}」'), 'を出品しました'], null));
      } else {
        _addMessageBackup(MessageModel(MessageType.SALES,
            [HighLight('「${data['item_name']}」'), 'が出品されました'], null));
      }
      setState(() {
        showButton = true;
      });
    } else if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      Future.delayed(Duration(milliseconds: 200), () {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            curve: Curves.bounceIn,
            duration: Duration(milliseconds: 100));
      });
    }
  }

  void _receiveSold(dynamic data) {
    if (_debugIllegalLiveId(data['live_id'])) return;

    if (widget.isLiver) {
      _addMessage(MessageModel(
          MessageType.SOLD,
          [
            HighLight('${data['nickname']}'),
            'が',
            HighLight('「${data['item_name']}」'),
            'を購入しました'
          ],
          data['user_id']));
    } else {
      _addMessage(MessageModel(MessageType.SOLD,
          [HighLight('「${data['item_name']}」'), 'が売り切れました'], null));
    }
    if(scrollController.position.pixels  < scrollController.position.maxScrollExtent) {
      if (widget.isLiver) {
        _addMessageBackup(MessageModel(
          MessageType.SOLD,
          [
            HighLight('${data['nickname']}'),
            'が',
            HighLight('「${data['item_name']}」'),
            'を購入しました'
          ],
          data['user_id']));
    } else {
        _addMessageBackup(MessageModel(MessageType.SOLD,
          [HighLight('「${data['item_name']}」'), 'が売り切れました'], null));
    }
      setState(() {
        showButton = true;
      });
    } else if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      Future.delayed(Duration(milliseconds: 200), () {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            curve: Curves.bounceIn,
            duration: Duration(milliseconds: 100));
      });
    }
  }

  void _addMessage(MessageModel message) {
    _insertMessage(message);
  }

  void _insertMessage(MessageModel message) {
    setState(() {
      _messages.insert(0, message);
      if (_messages.length > _MAX_MESSAGE) {
        _messages.removeLast();
      }
    });
  }

  void _addMessageBackup(MessageModel message) {
    _insertMessageBackup(message);
  }

  void _insertMessageBackup(MessageModel message) {
    setState(() {
      _messagesBackup.insert(0, message);
      if (_messagesBackup.length > _MAX_MESSAGE) {
        _messagesBackup.removeLast();
      }
    });
  }

  // デバッグ用：違うライブルームにいいねやギフトが飛ぶことがある？のを防止するための対策
  bool _debugIllegalLiveId(String liveId) {
    // ソケットに live_id が含まれない場合にもOKにする。
    return liveId != null && liveId != widget.liveId;
  }
}
