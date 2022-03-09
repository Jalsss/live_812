import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:live812/domain/model/ec/product.dart';
import 'package:live812/domain/model/ec/store_profile.dart';
import 'package:live812/ui/dialog/ec/product_image_dialog.dart';
import 'package:live812/ui/scenes/shop/store_profile_edit_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:provider/provider.dart';

class StoreProfileDetailPage extends StatelessWidget {
  final bool isSelf;
  final StoreProfile storeProfile;
  final Function(List<StoreProfile>) onUpdate;

  StoreProfileDetailPage(
      {this.isSelf = false, this.storeProfile, this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Provider<_StoreProfileDetailPageBloc>(
      create: (context) => _StoreProfileDetailPageBloc(
        isSelf: isSelf,
        storeProfile: storeProfile,
        onUpdate: onUpdate,
      ),
      dispose: (context, bloc) => bloc.dispose(),
      child: _StoreProfileDetailPage(),
    );
  }
}

class _StoreProfileDetailPage extends StatefulWidget {
  @override
  _StoreProfileDetailPageState createState() => _StoreProfileDetailPageState();
}

class _StoreProfileDetailPageState extends State<_StoreProfileDetailPage> {
  @override
  Widget build(BuildContext context) {
    final bloc =
        Provider.of<_StoreProfileDetailPageBloc>(context, listen: false);
    return LiveScaffold(
      backgroundColor: ColorLive.MAIN_BG,
      title: Lang.STORE_PROFILE,
      titleColor: Colors.white,
      body: StreamBuilder<StoreProfile>(
          initialData: null,
          stream: bloc.storeProfileStream,
          builder: (context, snapshot) {
            final storeProfile = snapshot.data;
            if (storeProfile == null) {
              return Container();
            }
            final imgUrls =
                storeProfile.imgUrls.where((x) => x != null).toList();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                imgUrls.isEmpty
                    ? Container(
                        height: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Text(
                                Lang.NO_IMAGE,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        height: 300,
                        margin: EdgeInsets.only(top: 10),
                        child: Swiper(
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(3)),
                                  border: Border.all(color: Colors.white),
                                ),
                                child: FadeInImage.assetNetwork(
                                  placeholder:
                                      Consts.LOADING_PLACE_HOLDER_IMAGE,
                                  image: imgUrls[index],
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
                                        Animation<double> secondaryAnimation) {
                                      return ProductImageDialog(
                                        url: imgUrls[index],
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          loop: false,
                          control: SwiperControl(color: Colors.white, size: 12),
                          viewportFraction: 0.8,
                          scale: 1,
                          itemCount: imgUrls.length,
                        ),
                      ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(20),
                    children: <Widget>[
                      Text(
                        storeProfile.itemName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        storeProfile.memo,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                bloc.isSelf
                    ? PrimaryButton(
                        text: Lang.DO_EDIT,
                        height: 60,
                        onPressed: () async {
                          await Navigator.push(context,
                              CupertinoPageRoute(builder: (context) {
                            return StoreProfileEditPage(
                              storeProfile: storeProfile,
                              onUpdate: (storeProfiles) async {
                                await bloc.onUpdate(storeProfiles);
                              },
                            );
                          }));
                        },
                      )
                    : Container(),
              ],
            );
          }),
    );
  }
}

class _StoreProfileDetailPageBloc {
  final _storeProfileStreamController = StreamController<StoreProfile>();

  Stream<StoreProfile> get storeProfileStream =>
      _storeProfileStreamController.stream;

  bool isSelf;
  int _index;
  Function(List<StoreProfile>) _onUpdate;

  _StoreProfileDetailPageBloc({
    bool isSelf,
    StoreProfile storeProfile,
    Function(List<StoreProfile>) onUpdate,
  }) {
    _storeProfileStreamController.sink.add(storeProfile);
    this.isSelf = isSelf;
    _index = storeProfile.index;
    _onUpdate = onUpdate;
  }

  Future onUpdate(List<StoreProfile> storeProfiles) async {
    final storeProfile = storeProfiles
        .firstWhere((element) => element.index == _index, orElse: () => null);
    if (storeProfile != null) {
      _storeProfileStreamController.sink.add(storeProfile);
    }
    if (_onUpdate != null) {
      await Future.value(_onUpdate(storeProfiles));
    }
  }

  void dispose() {
    _storeProfileStreamController?.close();
  }
}
