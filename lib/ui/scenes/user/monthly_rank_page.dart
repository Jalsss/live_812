import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:live812/domain/model/user/rank_type.dart';
import 'package:live812/domain/model/user/rank_user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/scenes/user/profile_view.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:provider/provider.dart';

class MonthlyRankPage extends StatelessWidget {
  final String userId;

  MonthlyRankPage({this.userId});

  @override
  Widget build(BuildContext context) {
    return Provider<_MonthlyRankPageBloc>(
      create: (context) => _MonthlyRankPageBloc(targetUserId: userId),
      dispose: (context, bloc) => bloc.dispose(),
      child: _MonthlyRankPage(),
    );
  }
}

class _MonthlyRankPage extends StatefulWidget {
  @override
  _MonthlyRankPageState createState() => _MonthlyRankPageState();
}

class _MonthlyRankPageState extends State<_MonthlyRankPage> {
  @override
  void initState() {
    super.initState();
    final bloc = Provider.of<_MonthlyRankPageBloc>(context, listen: false);
    bloc.requestRankType(context);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<_MonthlyRankPageBloc>(context, listen: false);
    return StreamBuilder<bool>(
      initialData: false,
      stream: bloc.loadingStream,
      builder: (context, snapshot) {
        return LiveScaffold(
          isLoading: false,
          title: "月間ランキング",
          titleColor: Colors.white,
          backgroundColor: ColorLive.MAIN_BG,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 60,
                color: ColorLive.BLUE_BG,
                child: StreamBuilder<List<RankType>>(
                  initialData: [],
                  stream: bloc.rankTypeListStream,
                  builder: (context, snapshot) {
                    var list = snapshot.data;
                    return DropdownButton<int>(
                      value: bloc.selectedRankType,
                      dropdownColor: ColorLive.BLUE_BG,
                      isExpanded: true,
                      iconEnabledColor: ColorLive.ORANGE,
                      icon: Icon(Icons.arrow_drop_down, size: 30),
                      style: const TextStyle(
                        color: ColorLive.ORANGE,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      items: list
                          .map((e) => DropdownMenuItem(
                                value: e.id,
                                child: Center(child: Text(e.name)),
                              ))
                          .toList(),
                      onChanged: (id) {
                        bloc.requestRank(context, id);
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<List<RankUser>>(
                  initialData: [],
                  stream: bloc.rankUserListStream,
                  builder: (context, snapshot) {
                    var list = snapshot.data;
                    return ListView.separated(
                      controller: bloc.scrollController,
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 1,
                          thickness: 1,
                          indent: 15,
                          endIndent: 15,
                          color: ColorLive.BORDER4.withAlpha(400),
                        );
                      },
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        var user = list[index];
                        return _RankListTile(
                          user: user,
                          targetUserId: bloc.targetUserId,
                          onTap: () async {
                            await bloc.showProfile(context, user.id);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MonthlyRankPageBloc {
  final String targetUserId;

  final scrollController = ScrollController();

  final _loadingStreamController = StreamController<bool>();

  Stream get loadingStream => _loadingStreamController.stream;

  final _rankTypeListStreamController = StreamController<List<RankType>>();

  Stream get rankTypeListStream => _rankTypeListStreamController.stream;
  final List<RankType> _rankTypeList = [];
  int selectedRankType;

  final _rankUserListStreamController = StreamController<List<RankUser>>();

  Stream get rankUserListStream => _rankUserListStreamController.stream;
  final List<RankUser> rankUserList = [];

  _MonthlyRankPageBloc({this.targetUserId});

  void _setLoading(bool value) {
    _loadingStreamController.sink.add(value);
  }

  void _setRankTypeList(List<RankType> list) {
    _rankTypeList.clear();
    _rankTypeList.addAll(list);
    _rankTypeList.sort((a, b) => a.sort - b.sort);
    _rankTypeListStreamController.sink.add(_rankTypeList);
  }

  void _setRankUserList(List<RankUser> list) {
    rankUserList.clear();
    rankUserList.addAll(list);
    rankUserList.sort((a, b) => a.rank - b.rank);
    _rankUserListStreamController.sink.add(rankUserList);

    var index =
        rankUserList.indexWhere((element) => element.id == targetUserId);
    if (index < 0) {
      return;
    }
    var targetPosition = (56.0 + 1.0) * index;
    Timer(
      Duration(milliseconds: 10),
      () {
        scrollController?.jumpTo(targetPosition);
      },
    );
  }

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

  Future requestRankType(BuildContext context) async {
    _setLoading(true);
    final service = BackendService(context);
    final response = await service.getRankList(userId: targetUserId);
    _setLoading(false);

    final result = response?.result ?? false;
    if (!result) {
      // エラー.
      _showErrorMessage(context, "エラー", "通信に失敗しました");
      return;
    }

    final List<dynamic> data = response.getData();
    List<RankType> list = [];
    for (var d in data) {
      list.add(RankType.fromJson(d));
    }
    if (list.length <= 0) {
      return;
    }
    selectedRankType = list.first.id;
    _setRankTypeList(list);
    await requestRank(context, selectedRankType);
  }

  Future requestRank(BuildContext context, int id) async {
    selectedRankType = id;
    final type = _rankTypeList.firstWhere((element) => element.id == id,
        orElse: () => null);
    final url = type?.url ?? "";
    if (url.isEmpty) {
      return;
    }
    _setLoading(true);
    final service = BackendService(context);
    final response = await service.getRank(url: url, userId: targetUserId);
    _setLoading(false);

    final result = response?.result ?? false;
    if (!result) {
      // エラー.
      _showErrorMessage(context, "エラー", "通信に失敗しました");
      _setRankUserList([]);
      return;
    }

    if (!(response.getData() is List<dynamic>)) {
      _setRankUserList([]);
      return;
    }

    final List<dynamic> data = response.getData();
    List<RankUser> list = [];
    for (var d in data) {
      list.add(RankUser.fromJson(d));
    }
    _setRankUserList(list);
  }

  Future showProfile(BuildContext context, String userId) async {
    await Navigator.push(
      context,
      FadeRoute(
        builder: (context) => ProfileViewPage(userId: userId),
      ),
    );
  }

  void dispose() {
    scrollController?.dispose();
    _loadingStreamController?.close();
    _rankTypeListStreamController?.close();
    _rankUserListStreamController?.close();
  }
}

class _RankListTile extends StatelessWidget {
  final RankUser user;
  final Function onTap;
  final String targetUserId;

  final formatter = NumberFormat("#,###");

  _RankListTile({this.user, this.onTap, this.targetUserId});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: user.id == targetUserId ? Color(0xffee4444) : null,
      child: ListTile(
        title: Text(
          user.nickname ?? '',
          style: const TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 32,
              child: Center(
                child: Text(
                  user.rank > 0 ? user.rank.toString() : "",
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 15.0,
                backgroundImage: NetworkImage(user.imgSmallUrl),
                backgroundColor: Colors.white.withAlpha(100),
                onBackgroundImageError: (d, s) {},
              ),
            ),
          ],
        ),
        trailing: Text(
          user.point != null ? formatter.format(user.point) : "",
          style: const TextStyle(
            fontFamily: "Roboto",
            color: Colors.yellow,
            fontWeight: FontWeight.w700,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
