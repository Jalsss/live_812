import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live812/domain/model/ec/product_template.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';

class ProductTemplateItem extends StatelessWidget {
  final ProductTemplate template;
  final Function onTap;

  ProductTemplateItem({
    @required this.template,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnailUrls =
        template.imgThumbUrls.where((x) => x != null).toList();

    return InkWell(
      onTap: onTap,
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 100,
                  height: 100,
                  child: thumbnailUrls.length > 0
                      ? FadeInImage.assetNetwork(
                          placeholder: Consts.LOADING_PLACE_HOLDER_IMAGE,
                          image: thumbnailUrls.first,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Text(
                            Lang.NO_IMAGE,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        template?.name ?? '',
                        softWrap: true,
                        style: TextStyle(color: Colors.white),
                      ),
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
      ),
    );
  }
}
