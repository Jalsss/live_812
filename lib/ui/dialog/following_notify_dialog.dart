import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/following_notify.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:provider/provider.dart';

class FollowingNotifyDialog extends StatelessWidget {
  final FollowingNotify _followingNotify;

  FollowingNotifyDialog(this._followingNotify);

  @override
  Widget build(BuildContext context) {
    return Provider<_FollowingNotifyDialogBloc>(
      create: (context) => _FollowingNotifyDialogBloc(_followingNotify),
      dispose: (context, bloc) => bloc.dispose(),
      child: Dialog(
        elevation: 0.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
        ),
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height - 200,
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: Consts.padding),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: ColorLive.BG2,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6.0),
                        topRight: Radius.circular(6.0),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: const Text(
                      "通知設定",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ColorLive.ORANGE),
                    ),
                  ),
                  Divider(
                    color: ColorLive.BORDER4,
                    thickness: 1,
                    height: 1,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 6.0),
                    height: 30,
                    child: Center(
                      child: Text(
                        "このライバーの通知を個別に設定します",
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ),
                  _FollowingNotifyDialogDivider(),
                  Consumer<_FollowingNotifyDialogBloc>(
                      builder: (context, bloc, child) {
                    return _FollowingNotifyDialogItem(
                      title: "ライブ配信開始",
                      initialData: _followingNotify.live,
                      stream: bloc.liveNotify,
                      onChanged: bloc.changeLiveNotify,
                    );
                  }),
                  _FollowingNotifyDialogDivider(),
                  Consumer<_FollowingNotifyDialogBloc>(
                      builder: (context, bloc, child) {
                    return _FollowingNotifyDialogItem(
                      title: "タイムライン投稿",
                      initialData: _followingNotify.timeline,
                      stream: bloc.timelineNotify,
                      onChanged: bloc.changeTimelineNotify,
                    );
                  }),
                  _FollowingNotifyDialogDivider(),
                  Consumer<_FollowingNotifyDialogBloc>(
                      builder: (context, bloc, child) {
                    return _FollowingNotifyDialogItem(
                      title: "商品出品",
                      initialData: _followingNotify.ec,
                      stream: bloc.exhibitionNotify,
                      onChanged: bloc.changeExhibitionNotify,
                    );
                  }),
                  _FollowingNotifyDialogDivider(),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 10,
                      top: 6.0,
                      right: 10,
                    ),
                    height: 60,
                    child: Text(
                      "・設定が有効になるまでに5分程度かかります\n・ライバー側が通知をOFFにしていた場合は、設定をONにしていても届きません",
                      style: TextStyle(fontSize: 10.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowingNotifyDialogBloc {
  final FollowingNotify _followingNotify;

  final _liveNotifyController = StreamController<bool>();
  final _timelineNotifyController = StreamController<bool>();
  final _exhibitionNotifyController = StreamController<bool>();

  Stream<bool> get liveNotify => _liveNotifyController.stream;
  Stream<bool> get timelineNotify => _timelineNotifyController.stream;
  Stream<bool> get exhibitionNotify => _exhibitionNotifyController.stream;

  _FollowingNotifyDialogBloc(this._followingNotify) {
    _liveNotifyController.sink.add(_followingNotify.live);
    _timelineNotifyController.sink.add(_followingNotify.timeline);
    _exhibitionNotifyController.sink.add(_followingNotify.ec);
  }

  Future changeLiveNotify(bool value) async {
    _followingNotify.live = value;
    _liveNotifyController.sink.add(value);
  }

  Future changeTimelineNotify(bool value) async {
    _followingNotify.timeline = value;
    _timelineNotifyController.sink.add(value);
  }

  Future changeExhibitionNotify(bool value) async {
    _followingNotify.ec = value;
    _exhibitionNotifyController.sink.add(value);
  }

  void dispose() {
    _liveNotifyController.close();
    _timelineNotifyController.close();
    _exhibitionNotifyController.close();
  }
}

class _FollowingNotifyDialogDivider extends Divider {
  _FollowingNotifyDialogDivider() : super(indent: 10, endIndent: 10);
}

class _FollowingNotifyDialogItem extends StatelessWidget {
  final String title;
  final bool initialData;
  final Stream stream;
  final Function(bool) onChanged;

  _FollowingNotifyDialogItem(
      {this.title, this.initialData, this.stream, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      initialData: initialData,
      stream: stream,
      builder: (context, snapshot) {
        return Container(
          height: 30.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                    value: snapshot.data,
                    activeColor: ColorLive.ORANGE,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
