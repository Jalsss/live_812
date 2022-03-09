import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FABBottomItem {
  final IconData iconData;
  final String text;
  final String imgUrl;
  final bool notice;

  FABBottomItem({this.iconData, this.text, this.imgUrl, this.notice = false});
}

class FABBottomAppBar extends StatelessWidget {
  FABBottomAppBar({
    this.items,
    this.activeIndex,
    this.centerItemText,
    this.height: 60.0,
    this.iconSize: 24.0,
    this.backgroundColor,
    this.normalColor,
    this.selectedColor,
    this.notchedShape,
    this.onTabSelected,
    this.isFab: false,
  }) {
    assert(this.items.length == 2 || this.items.length == 4);
  }

  final List<FABBottomItem> items;
  final int activeIndex;
  final String centerItemText;
  final double height;
  final double iconSize;
  final Color backgroundColor;
  final Color normalColor;
  final Color selectedColor;
  final NotchedShape notchedShape;
  final ValueChanged<int> onTabSelected;
  final bool isFab;

  @override
  Widget build(BuildContext context) {
    final widgets = List.generate(items.length, (int index) {
      return _buildTabItem(
        item: items[index],
        index: index,
        onPressed: onTabSelected,
      );
    });

    if (isFab)
      widgets.insert(items.length >> 1, _buildMiddleTabItem());

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
          child: BottomAppBar(
            shape: notchedShape,
            color: backgroundColor,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: widgets,
            ),
          )),
    );
  }

  Widget _buildMiddleTabItem() {
    return Expanded(
      child: SizedBox(
        height: height,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: iconSize),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    FABBottomItem item,
    int index,
    ValueChanged<int> onPressed,
  }) {
    Color color = index == activeIndex ? selectedColor : normalColor;
    String active = index == activeIndex ? "_active.svg" : ".svg";
    final svgPic = Center(
      child: SvgPicture.asset(
        '${item.imgUrl}$active',
        height: 20,
      ),
    );

    return Expanded(
      child: SizedBox(
        height: height,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onPressed(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: !item.notice ? svgPic : _buildNoticeIcon(svgPic),
                ),
                SizedBox(height: 2),
                Text(
                  item.text,
                  softWrap: false,
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeIcon(Widget svgPic) {
    return Stack(
      children: [
        svgPic,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 20),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
