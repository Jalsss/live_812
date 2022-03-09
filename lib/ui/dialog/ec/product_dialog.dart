import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:live812/domain/model/ec/product.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/consts/ColorLive.dart';

class ProductDialog extends StatelessWidget {
  final Product product;

  ProductDialog({this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: 300,
            child: product.imgUrlList.length == 0
                ? Container(
                    child: Center(
                        child: Text(Lang.NO_IMAGE,
                            style: TextStyle(color: Colors.grey))))
                : Swiper(
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                          border: Border.all(color: Colors.white),
                        ),
                        child: FadeInImage.assetNetwork(
                          placeholder: Consts.LOADING_PLACE_HOLDER_IMAGE,
                          image: product.imgUrlList[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                    loop: false,
                    control: product.imgUrlList.length < 2 ? null : SwiperControl(color: Colors.white, size: 12),
                    viewportFraction: 0.8,
                    scale: 1,
                    itemCount: product.imgUrlList.length,
                  ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 100,
          right: 100,
          height: 50,
          child: MaterialButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            padding: EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            color: ColorLive.BLUE,
            child: Text(
              Lang.CLOSE_CC,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}