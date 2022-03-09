import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:live812/domain/model/ec/store_profile.dart';
import 'package:live812/ui/dialog/ec/product_image_dialog.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';

/// ライブ配信中のストアプロフォール.
class StoreProfileCardItem extends StatelessWidget {
  final StoreProfile storeProfile;

  StoreProfileCardItem({this.storeProfile});

  @override
  Widget build(BuildContext context) {
    final thumbnails =
        storeProfile.imgThumbUrls.where((x) => x != null).toList();

    return OrientationBuilder(
      builder: (context, orientation) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          height: double.infinity,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: orientation == Orientation.landscape ? 90 : 120,
                margin: EdgeInsets.only(top: 4),
                child: 1 != 1
                    ? Container(
                        child: Text(
                          Lang.NO_IMAGE,
                          style: TextStyle(color: ColorLive.C26),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, size) {
                          return Swiper(
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(3)),
                                    border:
                                        Border.all(color: Color(0x40000000)),
                                  ),
                                  child: FadeInImage.assetNetwork(
                                    placeholder:
                                        Consts.LOADING_PLACE_HOLDER_IMAGE,
                                    image: thumbnails[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      opaque: false,
                                      pageBuilder: (BuildContext context,
                                          Animation<double> animation,
                                          Animation<double>
                                              secondaryAnimation) {
                                        return ProductImageDialog(
                                          url: thumbnails[index],
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                            loop: false,
                            control: thumbnails.length < 2
                                ? null
                                : SwiperControl(color: Colors.white, size: 12),
                            viewportFraction: size.maxHeight / size.maxWidth,
                            scale: 1,
                            itemCount: thumbnails.length,
                          );
                        },
                      ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(storeProfile.itemName),
                        SizedBox(height: 8),
                        Text(
                          storeProfile.memo,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
