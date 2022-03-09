import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';

class SettingItem extends StatelessWidget {
  const SettingItem({
    this.onTap,
    this.title,
  });

  final Function onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Divider(
            height: 0.5,
            thickness: 0.5,
            //color: Colors.white.withAlpha(20),
            color: ColorLive.DIVIDER,
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Text(
                    title,
                    softWrap: true,
                    maxLines: 3,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: ColorLive.ORANGE,
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
