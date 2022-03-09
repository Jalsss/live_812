import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live812/domain/model/ec/store_profile.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/item/store_profile_item.dart';
import 'package:live812/ui/scenes/shop/store_profile_detail_page.dart';
import 'package:live812/ui/scenes/shop/store_profile_edit_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/custom_validator.dart';
import 'package:live812/utils/image_util.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:live812/utils/widget/product_choose_image_view.dart';
import 'package:live812/utils/widget/product_image_view.dart';
import 'package:provider/provider.dart';

class StoreProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<_StoreProfilePageBloc>(
      create: (context) => _StoreProfilePageBloc(),
      dispose: (context, bloc) => bloc.dispose(),
      child: _StoreProfilePage(),
    );
  }
}

class _StoreProfilePage extends StatefulWidget {
  @override
  _StoreProfilePageState createState() => _StoreProfilePageState();
}

class _StoreProfilePageState extends State<_StoreProfilePage> {
  @override
  void initState() {
    super.initState();
    final bloc = Provider.of<_StoreProfilePageBloc>(context, listen: false);
    bloc.requestStoreProfile(context);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<_StoreProfilePageBloc>(context, listen: false);
    return StreamBuilder(
      initialData: false,
      stream: bloc.isLoading,
      builder: (context, snapshot) {
        return LiveScaffold(
          isLoading: snapshot.data,
          title: Lang.STORE_PROFILE,
          titleColor: Colors.white,
          backgroundColor: ColorLive.MAIN_BG,
          body: StreamBuilder<List<StoreProfile>>(
            initialData: null,
            stream: bloc.storeProfileListStream,
            builder: (context, snapshot) {
              final storeProfiles = snapshot.data;
              if (storeProfiles == null) {
                return Container();
              }
              return Column(
                children: <Widget>[
                  Expanded(
                    child: storeProfiles.isEmpty
                        ? const Center(
                            child: Text(
                              "ストアプロフィールはありません",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            itemCount: storeProfiles.length,
                            itemBuilder: (context, index) {
                              return StoreProfileItem(
                                storeProfile: storeProfiles[index],
                                onTap: () async {
                                  await bloc.onTapItem(
                                      context, storeProfiles[index]);
                                },
                              );
                            },
                          ),
                  ),
                  storeProfiles.length != Consts.STORE_PROFILE_MAX_LENGTH
                      ? PrimaryButton(
                          text: "新規ストアプロフィール登録",
                          height: 60,
                          onPressed: () async {
                            await Navigator.push(context,
                                CupertinoPageRoute(builder: (context) {
                              return StoreProfileEditPage();
                            }));
                            await bloc.requestStoreProfile(context);
                          },
                        )
                      : Container(),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _StoreProfilePageBloc {
  StreamController _loadingStreamController = StreamController<bool>();
  StreamController _storeProfileListStreamController =
      StreamController<List<StoreProfile>>();

  Stream<bool> get isLoading => _loadingStreamController.stream;

  Stream<List<StoreProfile>> get storeProfileListStream =>
      _storeProfileListStreamController.stream;

  List<StoreProfile> storeProfileList = [];

  _StoreProfilePageBloc();

  void onLoading(bool value) {
    _loadingStreamController.sink.add(value);
  }

  Future requestStoreProfile(BuildContext context) async {
    final service = BackendService(context);
    onLoading(true);
    final response = await service.getStoreProfile();
    onLoading(false);
    if (!(response?.result ?? true)) {
      // 通信エラー.
      _showDialog(context, "エラー", "通信に失敗しました");
      return;
    }
    storeProfileList = [];
    final data = response.getData() as List;
    if (data != null) {
      storeProfileList = data.map((x) => StoreProfile.fromJson(x)).toList();
    }
    _storeProfileListStreamController.sink.add(storeProfileList);
  }

  Future _showDialog(BuildContext context, String title, String message) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Future onTapItem(BuildContext context, StoreProfile storeProfile) async {
    await Navigator.push(
      context,
      FadeRoute(
        builder: (context) => StoreProfileDetailPage(
          isSelf: true,
          storeProfile: storeProfile,
          onUpdate: (storeProfiles) async {
            storeProfileList = storeProfiles;
            _storeProfileListStreamController.sink.add(storeProfileList);
          },
        ),
      ),
    );
  }

  void dispose() {
    _loadingStreamController?.close();
    _storeProfileListStreamController?.close();
  }
}
