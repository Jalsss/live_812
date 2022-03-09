import 'package:flutter/material.dart';
import 'package:live812/domain/model/ec/store_profile.dart';
import 'package:live812/ui/scenes/shop/store_profile_detail_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/route/fade_route.dart';

class StoreProfileItem extends StatelessWidget {
  final StoreProfile storeProfile;
  final Function onTap;

  StoreProfileItem({this.storeProfile, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              storeProfile.imgThumbUrls != null &&
                      storeProfile.imgThumbUrls.where((x) => x != null).length >
                          0
                  ? Container(
                      width: 100,
                      height: 100,
                      child: FadeInImage.assetNetwork(
                        placeholder: Consts.LOADING_PLACE_HOLDER_IMAGE,
                        image: storeProfile.imgThumbUrls
                            .where((x) => x != null)
                            .first,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      child: Center(
                          child: Text(Lang.NO_IMAGE,
                              style: TextStyle(color: Colors.grey))),
                    ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      storeProfile.itemName ?? '',
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(left: 110),
            child: Divider(
              height: 10,
              thickness: 1,
              color: ColorLive.BLUE_BG,
            ),
          ),
        ],
      ),
    );
  }
}
