import 'dart:math';

import 'package:flutter/material.dart';
import 'package:live812/domain/model/live/audience.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/profile_dialog.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/spinning_indicator.dart';
import 'package:provider/provider.dart';

class BottomSheetAudience extends StatefulWidget {
  final String liveId;
  final Function onBack;

  BottomSheetAudience({@required this.liveId, this.onBack});

  @override
  _BottomSheetAudienceState createState() => _BottomSheetAudienceState();
}

class _BottomSheetAudienceState extends State<BottomSheetAudience> {
  int _page = 0;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return FutureProvider<List<AudienceModel>>(
      create: (context) => _requestAudiences(context, _page),
      catchError: (_, error) {
        debugPrint(error.toString());
        return null;
      },
      child: Consumer<List<AudienceModel>>(
        builder: (context, list, _) {
          final mq = MediaQuery.of(context);
          return Container(
            height: 320,
            padding: EdgeInsets.only(
              bottom: mq.padding.bottom,
              left: max(mq.padding.left, 10),
              right: max(mq.padding.right, 10),
            ),
            color: ColorLive.BLUE_BG,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    MaterialButton(
                      minWidth: 50,
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      onPressed: () {
                        widget.onBack();
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            Lang.BACK_MENU,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          "視聴者数",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        SizedBox(width: 16),
                        Text(
                          list != null ? '${list.length}' : '-',
                          style: TextStyle(
                              color: ColorLive.ORANGE,
                              fontSize: 16,
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: _isLoading ? SpinningIndicator()
                      : list == null ? Center(child: Text('取得失敗', style: TextStyle(color: Colors.grey)))
                      : ListView(children: list
                            .map((audience) => _buildAudience(audience)).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAudience(AudienceModel audience) {
    return InkWell(
      onTap: () {
        _viewDetails(audience);
      },
      child: Container(
        //height: 80,
        child: Column(
          children: <Widget>[
            Divider(
              color: Colors.white.withAlpha(300),
              height: 1,
              thickness: 1,
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 22,
                  height: 22,
                  margin:
                  EdgeInsets.only(left: 10, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      shape: BoxShape.circle),
                  child: RawMaterialButton(
                    elevation: 2,
                    shape: CircleBorder(),
                    child: CircleAvatar(
                      radius: 15.0,
                      backgroundImage: NetworkImage(audience.imgSmallUrl),
                      backgroundColor: Colors.white.withAlpha(
                          100),
                    ),
                    onPressed: () {
                      _viewDetails(audience);
                    },
                  ),
                ),
                SizedBox(
                  width: 7,
                ),
                Text(
                  audience.nickname ?? '',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // TODO: ページング
  Future<List<AudienceModel>> _requestAudiences(BuildContext context, int page) async {
    final service = BackendService(context);
    final response = await service.getLiveUsers(widget.liveId);
    List<AudienceModel> list;
    if (response?.result == true) {
      list = [];
      response.getData().forEach((elem) {
        list.add(AudienceModel.fromJson(elem));
      });
    }
    setState(() => _isLoading = false);
    return list;
  }

  Future<void> _viewDetails(AudienceModel audience) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => ProfileDialog(userId: audience.id),
    );
  }
}
