import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:live812/domain/model/ec/purchase.dart';
import 'package:live812/domain/model/ec/purchase_message.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/scenes/shop/product_detail_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/date_format.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/purchase_header.dart';
import 'package:provider/provider.dart';

/// チャット画面.
class PurchaseChatPage extends StatelessWidget {
  final String orderId;

  PurchaseChatPage({this.orderId});

  @override
  Widget build(BuildContext context) {
    return Provider<_PurchaseChatBloc>(
      create: (context) => _PurchaseChatBloc(orderId: orderId),
      dispose: (context, bloc) => bloc.dispose(),
      child: _PurchaseChatPage(),
    );
  }
}

class _PurchaseChatPage extends StatefulWidget {
  @override
  _PurchaseChatPageState createState() => _PurchaseChatPageState();
}

class _PurchaseChatPageState extends State<_PurchaseChatPage> {
  @override
  void initState() {
    super.initState();
    final bloc = Provider.of<_PurchaseChatBloc>(context, listen: false);
    bloc.getMessages(context);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<_PurchaseChatBloc>(context, listen: false);
    return StreamBuilder<bool>(
      initialData: false,
      stream: bloc.isLoading,
      builder: (context, snapshot) {
        return WillPopScope(
          onWillPop: () async => snapshot.data,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: LiveScaffold(
              isLoading: snapshot.data,
              title: "取引ID : ${bloc.orderId}",
              titleColor: Colors.white,
              backgroundColor: ColorLive.MAIN_BG,
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  StreamBuilder<Purchase>(
                    initialData: null,
                    stream: bloc.purchase,
                    builder: (context, snapshot) {
                      return snapshot.data == null
                          ? Container()
                          : PurchaseHeader(
                              purchase: snapshot.data,
                              onTap: () async {
                                await bloc.onTapPurchaseHeader(
                                  context,
                                  snapshot.data,
                                );
                              },
                            );
                    },
                  ),
                  StreamBuilder<List<PurchaseMessage>>(
                    stream: bloc.messages,
                    builder: (context, snapshot) {
                      return Expanded(
                        child: (snapshot.data?.length ?? 0) == 0
                            ? const Center(
                                child: Text(
                                  "メッセージはありません",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : ListView.builder(
                                reverse: true,
                                controller: bloc.scrollController,
                                itemCount: snapshot.data?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final message = snapshot?.data[index];
                                  if (message.isSelf) {
                                    return _SentMessageWidget(
                                      message: message,
                                    );
                                  } else {
                                    return _ReceivedMessageWidget(
                                      message: message,
                                    );
                                  }
                                },
                              ),
                      );
                    },
                  ),
                  Container(
                    height: 30,
                    width: double.infinity,
                    child: RaisedButton.icon(
                      icon: const Icon(Icons.refresh, color: ColorLive.BLUE),
                      color: ColorLive.MAIN_BG,
                      label: const Text("会話を更新する"),
                      textColor: ColorLive.BLUE,
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        await bloc.getMessages(context);
                      },
                    ),
                  ),
                  SingleChildScrollView(
                    reverse: false,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            child: Form(
                              child: StreamBuilder<bool>(
                                initialData: null,
                                stream: bloc.isLiver,
                                builder: (context, snapshot) {
                                  return TextField(
                                    controller: bloc.textEditingController,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.left,
                                    decoration: InputDecoration(
                                      fillColor: Colors.white.withAlpha(20),
                                      filled: true,
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      disabledBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white10),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      errorBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      labelStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                      hintStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      hintText: snapshot.data == null
                                          ? ""
                                          : snapshot.data
                                              ? "購入者へコメントする"
                                              : "出品者へコメントする",
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                            ),
                            child: FlatButton(
                              color: ColorLive.BLUE,
                              disabledColor: ColorLive.BLUE_GR,
                              textColor: Colors.white,
                              child: Text(
                                "送信",
                                style: const TextStyle(fontSize: 14),
                              ),
                              onPressed: () async {
                                await bloc.postMessage(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PurchaseChatBloc {
  final String orderId;

  final _liverStreamController = StreamController<bool>();

  Stream get isLiver => _liverStreamController.stream;

  final _loadingStreamController = StreamController<bool>();

  Stream get isLoading => _loadingStreamController.stream;

  ScrollController scrollController = ScrollController();
  final textEditingController = TextEditingController();

  final _purchaseStreamController = StreamController<Purchase>();

  Stream get purchase => _purchaseStreamController.stream;

  final _messagesStreamController = StreamController<List<PurchaseMessage>>();

  Stream get messages => _messagesStreamController.stream;

  _PurchaseChatBloc({this.orderId}) {
    KeyboardVisibilityNotification().addNewListener(onShow: () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 一番下までスクロール.
        if (scrollController.hasClients) {
          scrollController.jumpTo(0.0);
        }
      });
    });
  }

  /// ローディングの設定.
  void _setLoading(bool isLoading) {
    _loadingStreamController.sink.add(isLoading);
  }

  /// メッセージの取得.
  Future getMessages(BuildContext context) async {
    final service = BackendService(context);
    _setLoading(true);
    final response = await service.getEcItemChat(orderId: orderId);
    _setLoading(false);

    if (!(response?.result ?? false)) {
      // 通信エラー.
      _showErrorMessage(context, "エラー", "通信に失敗しました");
      return;
    }

    final List<dynamic> data = response.getData();
    var list = List<PurchaseMessage>();
    for (var d in data) {
      list.add(PurchaseMessage.fromJson(d));
    }
    list.sort((a, b) => b.created.compareTo(a.created));
    _setMessages(list);
    if (response.containsKey("item")) {
      var purchase = Purchase.fromJson(response.getByKey("item"));
      _purchaseStreamController.sink.add(purchase);
      final userModel = Provider.of<UserModel>(context, listen: false);
      _liverStreamController.sink
          .add(userModel.symbol != purchase.purchaseUserId);
    }
  }

  /// メッセージの投稿.
  Future postMessage(BuildContext context) async {
    // 前後の空白を削除.
    String text = textEditingController.text.trim();
    if (text.length <= 0) {
      return;
    }

    final service = BackendService(context);
    _setLoading(true);
    final response = await service.postEcItemChat(
      orderId: orderId,
      message: text,
    );
    _setLoading(false);

    if (!(response?.result ?? false)) {
      // 通信エラー.
      _showErrorMessage(context, "エラー", "通信に失敗しました");
      return;
    }

    // 編集終了.
    textEditingController?.clear();
    FocusScope.of(context).unfocus();

    // メッセージの再取得.
    await getMessages(context);
  }

  /// メッセージを設定.
  void _setMessages(List<PurchaseMessage> list) {
    _messagesStreamController.sink.add(list);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 一番下までスクロール.
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
    });
  }

  /// エラーメッセージの表示.
  void _showErrorMessage(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
        );
      },
    );
  }

  /// ヘッダーをタップした時.
  Future onTapPurchaseHeader(BuildContext context, Purchase purchase) async {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      FadeRoute(
        builder: (context) => ProductDetailPage(
          product: purchase.getProductInfo(),
          showProfit: purchase.state == PurchaseState.Completed,
          purchase: purchase,
        ),
      ),
    );
  }

  void dispose() {
    _liverStreamController?.close();
    _loadingStreamController?.close();
    scrollController?.dispose();
    textEditingController?.dispose();
    _purchaseStreamController?.close();
    _messagesStreamController?.close();
  }
}

class _ReceivedMessageWidget extends StatelessWidget {
  final PurchaseMessage message;

  _ReceivedMessageWidget({this.message});

  static const Color _adminBgColor = Color(0xFFE18849);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            child: ClipOval(
              child: Image.network(message.imgUrl),
            ),
            radius: 18,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                message?.nickName ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Stack(
                    overflow: Overflow.visible,
                    alignment: Alignment.topLeft,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.6,
                        ),
                        decoration: BoxDecoration(
                          color: message?.isAdmin ?? false
                              ? _adminBgColor
                              : Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Text(
                          message?.message ?? "",
                        ),
                      ),
                      Positioned(
                        left: -10,
                        child: message?.isAdmin ?? false
                            ? Image.asset(
                                'assets/images/chat_orange.png',
                                scale: 2,
                              )
                            : Image.asset(
                                'assets/images/chat_white.png',
                                scale: 2,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 5),
                  Text(
                    dateFormatChat(message.created),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SentMessageWidget extends StatelessWidget {
  final PurchaseMessage message;

  _SentMessageWidget({this.message});

  static const Color _bgColor = Color(0xFF8EC073);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            dateFormatChat(message.created),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 5),
          Stack(
            overflow: Overflow.visible,
            alignment: Alignment.topRight,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                decoration: const BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Text(
                  message?.message ?? "",
                ),
              ),
              Positioned(
                right: -10,
                child: Image.asset(
                  'assets/images/chat_green.png',
                  scale: 2,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
