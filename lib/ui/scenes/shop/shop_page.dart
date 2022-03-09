import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:live812/domain/model/ec/store_profile.dart';
import 'package:live812/domain/model/user/badge_info.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/scenes/shop/product_template_form_page.dart';
import 'package:live812/ui/scenes/shop/product_template_page.dart';
import 'package:live812/ui/scenes/shop/store_profile_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/exclamation_badge.dart';
import 'package:provider/provider.dart';

class ShopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<_ShopPageBloc>(
      create: (context) => _ShopPageBloc(),
      dispose: (context, bloc) => bloc.dispose(),
      child: _ShopPage(),
    );
  }
}

class _ShopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final badgeInfo = Provider.of<BadgeInfo>(context, listen: true);
    final bloc = Provider.of<_ShopPageBloc>(context, listen: false);
    return StreamBuilder(
      initialData: false,
      stream: bloc.isLoading,
      builder: (context, snapshot) {
        return LiveScaffold(
          title: Lang.STORE,
          titleColor: Colors.white,
          backgroundColor: ColorLive.MAIN_BG,
          isLoading: snapshot.data,
          body: ListView(
            children: <Widget>[
              // 出品.
              userModel?.isLiver ?? false
                  ? Column(
                      children: <Widget>[
                        _ShopListHeader(
                          title: Lang.EXHIBIT,
                        ),
                        _ShopListTile(
                          title: Lang.EXHIBITING,
                          onTap: () {
                            bloc.onTapProduct(context);
                          },
                        ),
                        _ShopDivider(),
                        _ShopListTile(
                          title: Lang.DRAFTS,
                          onTap: () {
                            bloc.onTapDraft(context);
                          },
                        ),
                        _ShopDivider(),
                        _ShopListTile(
                          title: Lang.TRADING,
                          isBadge: badgeInfo.sales || badgeInfo.chatSales,
                          onTap: () async {
                            await bloc.onTapTradingSales(context);
                          },
                        ),
                        _ShopDivider(),
                        _ShopListTile(
                          title: Lang.PURCHASE_HISTORY_LIVER,
                          isBadge: badgeInfo.pastChatSales,
                          onTap: () async {
                            await bloc.onTapSalesHistory(context);
                          },
                        ),
                        _ShopDivider(),
                        _ShopListTile(
                          title: Lang.STORE_PROFILE,
                          onTap: () async {
                            await bloc.onTapStoreProfile(context);
                          },
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
              // 購入.
              Column(
                children: <Widget>[
                  _ShopListHeader(
                    title: Lang.BUYING,
                  ),
                  _ShopListTile(
                    title: Lang.TRADING,
                    isBadge: badgeInfo.purchase || badgeInfo.chatPurchase,
                    onTap: () async {
                      await bloc.onTapTradingPurchase(context);
                    },
                  ),
                  _ShopDivider(),
                  _ShopListTile(
                    title: Lang.PURCHASE_HISTORY,
                    isBadge: badgeInfo.pastChatPurchase,
                    onTap: () async {
                      await bloc.onTapPurchaseHistory(context);
                    },
                  ),
                  userModel?.isLiver ?? false
                      ? SizedBox.shrink()
                      : _ShopDivider(),
                ],
              ),
              // テンプレート.
              userModel?.isLiver ?? false
                  ? Column(
                      children: <Widget>[
                        _ShopListHeader(
                          title: Lang.TEMPLATES,
                        ),
                        _ShopListTile(
                          title: Lang.NEW_REGISTRATION,
                          onTap: () async {
                            await bloc.onTapAddTemplate(context);
                          },
                        ),
                        _ShopDivider(),
                        _ShopListTile(
                          title: Lang.EDIT,
                          onTap: () async {
                            await bloc.onTapEditTemplate(context);
                          },
                        ),
                        _ShopDivider(),
                      ],
                    )
                  : SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }
}

class _ShopPageBloc {
  final StreamController _loadingStreamController = StreamController<bool>();

  Stream get isLoading => _loadingStreamController.stream;

  _ShopPageBloc();

  /// バッジの更新.
  Future _updateBadgeInfo(BuildContext context) async {
    final badgeInfo = Provider.of<BadgeInfo>(context, listen: false);
    _loadingStreamController.sink.add(true);
    await badgeInfo.requestMyInfoBadge(context);
    _loadingStreamController.sink.add(false);
  }

  /// 出品中ボタン押下.
  void onTapProduct(BuildContext context) {
    Navigator.pushNamed(context, '/mypage/products');
  }

  /// 下書きボタン押下.
  void onTapDraft(BuildContext context) {
    Navigator.pushNamed(context, '/mypage/draft');
  }

  /// 出品の取引中ボタン押下.
  Future<void> onTapTradingSales(BuildContext context) async {
    await Navigator.pushNamed(context, '/mypage/sales/trading');
    _updateBadgeInfo(context);
  }

  /// 販売履歴ボタン押下.
  Future<void> onTapSalesHistory(BuildContext context) async {
    await Navigator.pushNamed(context, '/mypage/sales');
    _updateBadgeInfo(context);
  }

  /// ストアプロフィールボタン押下.
  Future<void> onTapStoreProfile(BuildContext context) async {
    await Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return StoreProfilePage();
    }));
  }

  /// 購入の取引中ボタン押下.
  Future<void> onTapTradingPurchase(BuildContext context) async {
    await Navigator.pushNamed(context, '/mypage/purchases/trading');
    _updateBadgeInfo(context);
  }

  /// 購入履歴ボタン押下.
  Future<void> onTapPurchaseHistory(BuildContext context) async {
    await Navigator.pushNamed(context, '/mypage/purchases');
    _updateBadgeInfo(context);
  }

  /// テンプレート新規登録ボタン押下.
  Future<void> onTapAddTemplate(BuildContext context) async {
    await Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return ProductTemplateFormPage();
    }));
  }

  /// テンプレート編集ボタン押下.
  Future onTapEditTemplate(BuildContext context) async {
    await Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return ProductTemplatePage();
    }));
  }

  void dispose() {
    _loadingStreamController?.close();
  }
}

class _ShopListHeader extends StatelessWidget {
  final String title;

  _ShopListHeader({this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: EdgeInsets.symmetric(
        horizontal: 10,
      ),
      color: ColorLive.BLUE_BG,
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ShopListTile extends StatelessWidget {
  final String title;
  final bool isBadge;
  final Function onTap;

  _ShopListTile({this.title, this.isBadge, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      dense: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          isBadge ?? false ? ExclamationBadge() : SizedBox.shrink(),
          Icon(
            Icons.navigate_next,
            color: ColorLive.ORANGE,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _ShopDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0.5,
      thickness: 0.5,
      indent: 15,
      endIndent: 15,
      color: ColorLive.DIVIDER,
    );
  }
}
