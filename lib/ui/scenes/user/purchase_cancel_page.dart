import 'package:flutter/material.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/utils/widget/ec_product_price_text.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';

enum PurchaseCancelResult {
  Canceled,  // キャンセルした
}

class PurchaseCancelPage extends StatefulWidget {
  final String provideUserId; // 商品提供者のID
  final String orderId; // 購入時に返るID
  final String name; // 商品名
  final int price; // 価格

  PurchaseCancelPage(
      this.provideUserId, this.orderId, this.name, this.price);

  @override
  PurchaseCancelPageState createState() => PurchaseCancelPageState();
}

class PurchaseCancelPageState extends State<PurchaseCancelPage> {
  TextEditingController _controller;
  bool _isSend = false;
  bool _isLoading = false;

  int _cancelTargetGroupValue = 0;
  bool get _isTargetProvider => _cancelTargetGroupValue == 0;
  final List<String> _cancelTargetTitles = [
    "出品者",
    "購入者",
  ];
  int _cancelProviderGroupValue = 0;
  final List<String> _cancelProviderTitles = [
    "運送会社での破損の為",
    "商品在庫が不足の為",
    "その他",  // 必ず最後にしてください.
  ];
  int _cancelUserGroupValue = 0;
  final List<String> _cancelUserTitles = [
    "購入商品を間違えた為",
    "その他",  // 必ず最後にしてください.
  ];

  bool get _isOther => _isTargetProvider
      ? _cancelProviderGroupValue == _cancelProviderTitles.length - 1
      : _cancelUserGroupValue == _cancelUserTitles.length - 1;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  Future<void> _requestPurchaseCancel() async {
    bool confirm = await showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("取引キャンセル"),
        content: Text("取引をキャンセルします。本当によろしいですか？"),
        actions: <Widget>[
          FlatButton(
            child: Text("いいえ"),
            onPressed: () => Navigator.pop(context, false),
          ),
          FlatButton(
            child: Text("はい"),
            onPressed: () => Navigator.pop(context, true),
          )
        ],
      );
    }) == true;

    if (!confirm) {
      return;
    }

    String message = _isOther
        ? _controller.text
        : (_isTargetProvider
        ? _cancelProviderTitles[_cancelProviderGroupValue]
        : _cancelUserTitles[_cancelUserGroupValue]);
    var service = BackendService(context);
    setState(() => _isLoading = true);
    final response = await service.postPurchaseCancel(
      widget.provideUserId,
      widget.orderId,
      message,
      _isTargetProvider,
    );
    setState(() => _isLoading = false);
    if (response != null && response.result) {
      setState(() => _isSend = true);
    } else {
      showNetworkErrorDialog(context, msg: response?.getByKey('msg'));
    }
  }

  void _setCancelTargetGroupValue(int value) {
    setState(() {
      _cancelTargetGroupValue = value;
    });
  }

  void _setCancelProviderGroupValue(int value) {
    setState(() {
      _cancelProviderGroupValue = value;
    });
  }

  void _setCancelUserGroupValue(int value) {
    setState(() {
      _cancelUserGroupValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
        isLoading: _isLoading,
        backgroundColor: ColorLive.MAIN_BG,
        title: _isSend ? '' : Lang.PURCHASE_CANCEL,
        titleColor: Colors.white,
        onClickBack: () {
          if (_isSend)
            Navigator.of(context).pop(PurchaseCancelResult.Canceled);
          else
            Navigator.of(context).pop();
        },
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              top: 0,
              bottom: 60,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _isSend
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: const Text(
                                '以下の内容でキャセルを申し込みました。\nキャンセル完了までいましばらくお待ちください。',
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    "原則キャンセルは致しかねます。",
                                    style: const TextStyle(
                                      color: ColorLive.RED,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Text(
                                    "(他決済・振込等にかかった手数料はキャンセル理由対象者側にご負担していただきます。)",
                                    style: const TextStyle(
                                      color: ColorLive.RED,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      Divider(
                        height: 24,
                        thickness: 1,
                        color: Colors.white.withAlpha(20),
                      ),
                      const Text(
                        "取引ID",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.orderId,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Divider(
                        height: 24,
                        thickness: 1,
                        color: Colors.white.withAlpha(20),
                      ),
                      const Text(
                        "商品名",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.name,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Divider(
                        height: 24,
                        thickness: 1,
                        color: Colors.white.withAlpha(20),
                      ),
                      const Text(
                        "金額",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      EcProductPriceText(
                        widget?.price,
                        priceTextStyle:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        includePostageTextStyle:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Divider(
                        height: 24,
                        thickness: 1,
                        color: Colors.white.withAlpha(20),
                      ),
                      const Text(
                        "キャンセル理由対象者",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 12),
                        child: Theme(
                          data: ThemeData(
                            unselectedWidgetColor: Colors.white,
                          ),
                          child: Row(
                            children: List.generate(_cancelTargetTitles.length, (index) {
                              return _CancelRadioText<int>(
                                title: _cancelTargetTitles[index],
                                value: index,
                                groupValue: _cancelTargetGroupValue,
                                onChanged: !_isSend
                                    ? _setCancelTargetGroupValue
                                    : null,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const Text(
                        "キャンセルの理由",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(height: 7),
                      _isTargetProvider
                          ? Container(
                              padding: const EdgeInsets.only(left: 12),
                              child: Theme(
                                data: ThemeData(
                                  unselectedWidgetColor: Colors.white,
                                ),
                                child: Column(
                                  children: List.generate(
                                      _cancelProviderTitles.length, (index) {
                                    return _CancelRadioText<int>(
                                      title: _cancelProviderTitles[index],
                                      value: index,
                                      groupValue: _cancelProviderGroupValue,
                                      onChanged: !_isSend
                                          ? _setCancelProviderGroupValue
                                          : null,
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.only(left: 12),
                              child: Theme(
                                data: ThemeData(
                                  unselectedWidgetColor: Colors.white,
                                ),
                                child: Column(
                                  children: List.generate(
                                      _cancelUserTitles.length, (index) {
                                    return _CancelRadioText<int>(
                                      title: _cancelUserTitles[index],
                                      value: index,
                                      groupValue: _cancelUserGroupValue,
                                      onChanged: !_isSend
                                          ? _setCancelUserGroupValue
                                          : null,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                      _isOther
                          ? Container(
                              padding: EdgeInsets.only(left: 60),
                              child: TextField(
                                controller: _controller,
                                minLines: 1,
                                maxLines: 1,
                                enabled: !_isSend,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  fillColor: Colors.white.withAlpha(20),
                                  filled: true,
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                  ),
                                  hintText: Lang.ENTER_TEXT,
                                  labelStyle: const TextStyle(color: Colors.white),
                                  hintStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      const SizedBox(height: 14),
                      Text(
                        _isTargetProvider
                            ? "事務手数料として330円を出品者様の売上金から差し引いてお支払いします。"
                            : "事務手数料としてお振込金額より330円を差し引いて購入者様へ返金いたします。",
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 60.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    //end: Alignment.centerRight,s
                    colors: [ColorLive.BLUE, ColorLive.BLUE_GR],
                    //colors: [Color(0xFF2C7BE5), const Color(0xFF2C7BE5)],
                  ),
                ),
                child: FlatButton(
                  textColor: Colors.white,
                  onPressed: () {
                    if (_isSend) {
                      Navigator.of(context).pop(PurchaseCancelResult.Canceled);
                    } else {
                      _requestPurchaseCancel();
                    }
                  },
                  child: Text(
                    _isSend ? "購入履歴へ戻る" : Lang.DO_SEND,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

class _CancelRadioText<T> extends StatelessWidget {
  final String title;
  final T value;
  final T groupValue;
  final Function(T) onChanged;

  _CancelRadioText({
    @required this.title,
    @required this.value,
    @required this.groupValue,
    @required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Radio<T>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        GestureDetector(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          onTap: () {
            if (onChanged != null) {
              onChanged(value);
            }
          },
        ),
      ],
    );
  }
}