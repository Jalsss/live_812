import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/user/other_user.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/ui/item/LiverGridItem.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/debug_util.dart';
import 'package:live812/utils/focus_util.dart';
import 'package:provider/provider.dart';

class SearchLive extends StatefulWidget {
  const SearchLive({
    this.word,
  });

  final String word;

  @override
  _SearchLiveState createState() => _SearchLiveState();
}

class _SearchLiveState extends State<SearchLive>
    with AutomaticKeepAliveClientMixin<SearchLive> {
  final _searchController = TextEditingController();
  bool _isLiver;
  bool _canSend = false;
  List<OtherUserModel> _liveRoomInfoList = [];
  bool _isShowRecommendation = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final userModel = Provider.of<UserModel>(context, listen: false);
    _isLiver = userModel.isLiver;
    _searchController.text = widget.word;
    Future(() {
      if (mounted) {
        _requestSearch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () => FocusUtil.unFocus(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('検索'),
          centerTitle: true,
          backgroundColor: ColorLive.MAIN_BG,
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset("assets/svg/backButton.svg"),
            onPressed: () {
              FocusUtil.unFocus(context);
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: ColorLive.MAIN_BG,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        clearButtonMode: OverlayVisibilityMode.editing,
                        prefix: const Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: const Icon(
                            Icons.search,
                            color: CupertinoColors.placeholderText,
                          ),
                        ),
                        prefixMode: OverlayVisibilityMode.notEditing,
                        placeholder: Lang.SEARCH_HINT,
                        onChanged: (value) {
                          setState(() {});
                        },
                        onSubmitted: (value) async {
                          _requestSearch();
                          FocusUtil.unFocus(context);
                        },
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      const SizedBox(width: 10),
                    if (_searchController.text.isNotEmpty)
                      Container(
                        height: 32,
                        child: ElevatedButton(
                          child: const Text(
                            Lang.SEARCH,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: ColorLive.BLUE,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            _requestSearch();
                            FocusUtil.unFocus(context);
                          },
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                children: !_isShowRecommendation
                    ? []
                    : [
                        const SizedBox(height: 8),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SvgPicture.asset(
                                "assets/svg/electric.svg",
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                "おすすめのライバー",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
              ),
              Expanded(
                child: Container(
                  margin:
                      const EdgeInsets.only(left: 15.0, top: 7.0, right: 15),
                  child: GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: .7,
                    children: _liveRoomInfoList
                        .map((info) => LiverGridItem(info))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _requestRecommendation() async {
    final userId = Provider.of<UserModel>(context, listen: false).id;
    final service = BackendService(context);
    final response = await service.getRecommendation(userId);
    if (response != null && response.result) {
      final data = response.getData();
      List<OtherUserModel> recommendations = [];
      for (final info in data) {
        recommendations.add(OtherUserModel.fromJson(info));
      }
      _setStateSafe(() {
        _liveRoomInfoList = recommendations;
        _isShowRecommendation = true;
      });
    } else {
      if (context != null) {
        showNetworkErrorDialog(context);
      } else {
        debugPrint('context is null');
        DebugUtil.dumpStackTrace(5);
      }
    }
  }

  Future<void> _requestSearch() async {
    final keyword = _searchController.text;

    final service = BackendService(context);
    final response = await service.searchLiver(keyword,
        isLiver: !_isLiver); // 自分がライバーの場合、ライバー以外のリスナーも検索対象に含める
    if (response != null && response.result) {
      setState(() {
        _liveRoomInfoList.clear();
        final data = response.getData() as List;
        if (data != null) {
          data.forEach((d) {
            _liveRoomInfoList.add(OtherUserModel.fromJson(d));
          });
        }
        _isShowRecommendation = false;
      });
    } else {
      showNetworkErrorDialog(context);
    }
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
