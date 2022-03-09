import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModalOverlay extends ModalRoute<void> {
  final Widget child;
  final bool isAndroidBackEnable;

  ModalOverlay({this.child, this.isAndroidBackEnable = true}) : super();

  @override
  Duration get transitionDuration => Duration(milliseconds: 50);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.2);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Center(
          child: WillPopScope(
            child: this.child,
            onWillPop: () {
              return Future(() => isAndroidBackEnable);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
