import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live812/utils/modal_overlay.dart';

class IndicatorView {
  IndicatorView._();

  static bool _isShow = false;

  static show(BuildContext context) {
    _isShow = true;
    Navigator.push(
      context,
      ModalOverlay(
        child: Center(
          child: CircularProgressIndicator(),
        ),
        isAndroidBackEnable: false,
      ),
    );
  }

  static hide(BuildContext context) {
    if (!_isShow) {
      return;
    }
    Navigator.of(context).pop();
    _isShow = false;
  }
}
