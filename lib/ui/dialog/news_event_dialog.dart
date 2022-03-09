import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:live812/domain/model/user/news_event.dart';
import 'package:live812/domain/usecase/live_event_usecase.dart';
import 'package:live812/ui/scenes/live_event/live_event_detail_page.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/modal_overlay.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:live812/ui/scenes/user/profile_view.dart';

class NewsEventDialog extends StatelessWidget {
  final List<NewsEvent> listNewsEvent;
  final int index;
  NewsEventDialog({this.listNewsEvent, this.index});

  @override
  Widget build(BuildContext context) {
    return Provider<_NewsEventDialogBloc>(
      create: (context) => _NewsEventDialogBloc(listNewsEvent: listNewsEvent, index : index),
      dispose: (context, bloc) => bloc.dispose(),
      child: _NewsEventDialog(),
    );
  }
}

class _NewsEventDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewsEventDialogState();
}

class _NewsEventDialogState extends State<_NewsEventDialog> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<_NewsEventDialogBloc>(context, listen: false);
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(border: Border.all(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),),
        color: Colors.white,),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Html(
                  data: bloc.listNewsEvent[bloc.index]?.body ?? "",
                  defaultTextStyle: TextStyle(color: Colors.black),
                  onLinkTap:(url) {
                    bloc.onLinkTap(url, context);
                  },
                ),
                bloc.listNewsEvent[bloc.index].imgUrl.isNotEmpty
                    ? Image.network(bloc.listNewsEvent[bloc.index].imgUrl)
                    : Container(),
                Container(
                  height: 105,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 45,
                color: Colors.white,
                child: StreamBuilder<bool>(
                    initialData: bloc.isRead,
                    stream: bloc.isReadStream,
                    builder: (context, snapshot) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Checkbox(
                            value: snapshot.data,
                            onChanged: bloc.setRead,
                          ),
                          GestureDetector(
                            child: const Text("次回以降は表示させない"),
                            onTap: () {
                              bloc.setRead(!snapshot.data);
                            },
                          ),
                        ],
                      );
                    }),
              ),
              PrimaryButton(
                text: Lang.CLOSE_CC,
                height: 60,
                onPressed: () async {
                  await bloc.onCloseTap(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewsEventDialogBloc {
  final List<NewsEvent> listNewsEvent;
  int index;
  StreamController<bool> isReadStreamController = StreamController<bool>();

  Stream<bool> get isReadStream => isReadStreamController.stream;
  bool isRead = false;

  _NewsEventDialogBloc({this.listNewsEvent, this.index});

  void setRead(bool value) {
    isRead = value;
    isReadStreamController.sink.add(value);
  }

  Future onCloseTap(BuildContext context) async {
    final newsEventModel = Provider.of<NewsEventModel>(context, listen: false);
    if (isRead) {
      // 現在の既読データを保存.
      await newsEventModel.setLastReadDate(listNewsEvent[index].dateTime);
    }
    // 表示した物を保存.
    List<String> listId = await newsEventModel.getListShowId();
    if(!listId.contains(listId)) {
      listId.add(listNewsEvent[index].id);
      await newsEventModel.setListShowId(listId);
    }
    await newsEventModel.setLastShowDate(DateTime.now());

    // 閉じる.
    Navigator.pop(context);
    if(listNewsEvent.length > index + 1) {
      index += 1;
      Navigator.push(
        context,
        ModalOverlay(
          child: NewsEventDialog(
            listNewsEvent: listNewsEvent,
            index: index,
          )
        ),
      );
    }
  }

  Future onLinkTap(String url, BuildContext context) async {
    final RegExp reUserDetailUrl = RegExp(r'^https?://share\.live812\.works/user/(\w+)$');
    final RegExp reEventDetailUrl = RegExp(r'^https?://share\.live812\.works/event/(\w+)$');
    RegExpMatch m;
    if ((m = reUserDetailUrl.firstMatch(url)) != null) {
      final userId = m.group(1);
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProfileViewPage(userId: userId)));
    } else if ((m = reEventDetailUrl.firstMatch(url)) != null) {
      final eventId = m.group(1);
      var liveEvent = await LiveEventUseCase.requestLiveEventOverView(context, eventId);
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LiveEventDetailPage(liveEvent: liveEvent)));
    } else {
      if (await canLaunch(url)) {
        await launch(url, forceSafariVC: false);
      } else {
        throw 'Could not Launch $url';
      }
    }
  }

  void dispose() {
    isReadStreamController?.close();
  }
}
