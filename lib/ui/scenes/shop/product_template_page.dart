import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live812/domain/model/ec/product_template.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/item/product_template_item.dart';
import 'package:live812/ui/scenes/shop/product_template_form_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:provider/provider.dart';

/// テンプレート一覧画面.
class ProductTemplatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<_ProductTemplateBloc>(
      create: (context) => _ProductTemplateBloc(),
      dispose: (context, bloc) => bloc.dispose(),
      child: ProductTemplatePageList(),
    );
  }
}

class ProductTemplatePageList extends StatefulWidget {
  @override
  _ProductTemplatePageListState createState() =>
      _ProductTemplatePageListState();
}

class _ProductTemplatePageListState extends State<ProductTemplatePageList> {
  @override
  void initState() {
    super.initState();
    final bloc = Provider.of<_ProductTemplateBloc>(context, listen: false);
    bloc.requestTemplate(context);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<_ProductTemplateBloc>(context, listen: false);
    return StreamBuilder<bool>(
      initialData: false,
      stream: bloc.isLoading,
      builder: (context, snapshot) {
        return LiveScaffold(
          title: Lang.TEMPLATES,
          titleColor: Colors.white,
          backgroundColor: ColorLive.MAIN_BG,
          isLoading: snapshot.data,
          body: Column(
            
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: const Text(
                  '※テンプレート名を基準に昇順で表示されます',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: bloc.templates.length == 0
                      ? Center(
                          child: Text(
                            Lang.ERROR_NO_PRODUCT_TEMPLATES,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemBuilder: (context, index) {
                            return ProductTemplateItem(
                              template: bloc.templates[index],
                              onTap: () async {
                                await bloc.onTapItem(context, index);
                              },
                            );
                          },
                          itemCount: bloc.templates.length,
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

class _ProductTemplateBloc {
  /// ローディング.
  StreamController<bool> _loadingStreamController = StreamController();

  Stream get isLoading => _loadingStreamController.stream;

  final List<ProductTemplate> templates = List<ProductTemplate>();

  _ProductTemplateBloc();

  void _setLoading(bool value) {
    _loadingStreamController.sink.add(value);
  }

  /// テンプレートを取得.
  Future requestTemplate(BuildContext context) async {
    _setLoading(true);
    final service = BackendService(context);
    final response = await service.getEcTemplate();

    templates.clear();
    if (response?.result ?? false) {
      List<dynamic> dataList = response.getData();
      if (dataList != null) {
        for (int i = 0; i < dataList.length; i++) {
          templates.add(ProductTemplate.fromJson(dataList[i]));
        }
      }
    }
    _setLoading(false);
  }

  /// ボタンを押下.
  Future onTapItem(BuildContext context, int index) async {
    var template =
        await Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return ProductTemplateFormPage(
        template: templates[index],
      );
    }));
    if (template != null) {
      // 画面更新.
      await requestTemplate(context);
    }
  }

  void dispose() {
    _loadingStreamController?.close();
  }
}
