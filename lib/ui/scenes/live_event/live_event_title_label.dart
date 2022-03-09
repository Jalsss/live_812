import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';

class LiveEventTitleLabel extends StatelessWidget {
  const LiveEventTitleLabel({
    this.icon,
    this.child,
    this.color = ColorLive.ORANGE,
  });

  final Widget icon;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) icon,
          if (icon != null) const SizedBox(width: 4),
          child,
        ],
      ),
    );
  }
}
