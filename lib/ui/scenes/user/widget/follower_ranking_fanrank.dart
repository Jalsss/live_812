import 'package:flutter/material.dart';
import 'package:live812/ui/dialog/fan_rank_dialog.dart';
import 'package:live812/ui/scenes/user/monthly_rank_page.dart';
import 'package:live812/ui/scenes/user/follower_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/consts/language.dart';

// フォロワー・月間ランキング・「ファンランク」を１列で表示するビュー
class FollowerRankingFanrankView extends StatelessWidget {
  final int followerCount;
  final String monthlyRanking;
  final String userId;

  FollowerRankingFanrankView({@required this.followerCount, @required this.monthlyRanking, @required this.userId});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                onTap: followerCount == null ? null : () {
                  Navigator.push(
                      context,
                      FadeRoute(
                          builder: (context) => FollowerPage(userId: userId,)));
                },
                child: Column(
                  children: <Widget>[
                    Text(
                      Lang.FOLLOWER,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12),
                    ),
                    Row(
                      children: [
                        Text(
                          followerCount != null ? followerCount.toString() : '-',
                          style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 20,
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 12,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      FadeRoute(
                          builder: (context) => MonthlyRankPage(userId: this.userId)));
                },
                child: Column(
                  children: <Widget>[
                    Text(
                      "月間ランキング",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12),
                    ),
                    Row(
                      children: [
                        Text(
                          monthlyRanking == null  ? '-' : monthlyRanking,
                          style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 20,
                              fontFamily: "Roboto",
                              fontWeight:
                              FontWeight.bold),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 12,
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Row(
          children: <Widget>[
            MaterialButton(
              minWidth: 20,
              onPressed: () {
                _viewFanRank(context);
              },
              padding:
              EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(5.0),
              ),
              color: ColorLive.BLUE,
              child: Row(
                children: <Widget>[
                  Text(
                    "ファンランク",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12),
                  ),
                  SizedBox(width: 20),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 12,
                  )
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  _viewFanRank(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => FanRankDialog(userId: userId,),
    );
  }
}
