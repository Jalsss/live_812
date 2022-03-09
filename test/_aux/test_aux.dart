import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Finder findDecorationNetworkImage({String url}) {
  return find.byWidgetPredicate((Widget widget) {
    if (widget is Container &&
        widget.decoration is BoxDecoration &&
        (widget.decoration as BoxDecoration).image is DecorationImage &&
        (widget.decoration as BoxDecoration).image.image is NetworkImage) {
      final image = (widget.decoration as BoxDecoration).image.image as NetworkImage;
      return url == null || image.url == url;
    }
    return false;
  });
}
