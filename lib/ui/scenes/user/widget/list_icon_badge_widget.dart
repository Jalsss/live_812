import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live812/ui/scenes/user/model/icon_badge_model.dart';

class ListIconBadge extends StatelessWidget {
  final List<IconBadge> listIconBadge;
  final bool showAllBadge;
  final Function() showAll;
  final Color colorsDropdown;

  ListIconBadge(
      {Key key,
      this.listIconBadge,
      this.showAllBadge,
      this.showAll,
      this.colorsDropdown = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        listIconBadge.length > 0
            ? Text('獲得バッジ',
                style: TextStyle(
                  color: colorsDropdown,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ))
            : SizedBox(),
        SizedBox(
          height: 10,
        ),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Wrap(
              alignment: WrapAlignment.center,
              children: List.generate(
                  listIconBadge.length > 8
                      ? (!showAllBadge ? 8 : listIconBadge.length)
                      : listIconBadge.length, (index) {
                return GestureDetector(
                  onTap: () {
                    showDialog(
                        context: (context),
                        builder: (context) {
                          return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              insetPadding:
                                  EdgeInsets.symmetric(horizontal: 40),
                              elevation: 0,
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 15),
                                  child:
                                      MediaQuery.of(context).orientation ==
                                                  Orientation.portrait &&
                                              MediaQuery.of(context).size.width <
                                                  550
                                          ? Stack(
                                              alignment: Alignment.topRight,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      top: 20, bottom: 15),
                                                  constraints: BoxConstraints(
                                                    maxHeight:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.7,
                                                  ),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.95,
                                                  child: SingleChildScrollView(
                                                      child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Image.network(
                                                        listIconBadge[index]
                                                            .imagePath,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                          listIconBadge[index]
                                                              .title,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 17)),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                          listIconBadge[index]
                                                              .description,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 15)),
                                                      SizedBox(
                                                        height: 30,
                                                      ),
                                                    ],
                                                  )),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Icon(Icons.clear),
                                                ),
                                              ],
                                            )
                                          : SizedBox(
                                              height: MediaQuery.of(context).size.width > 550 &&
                                                      MediaQuery.of(context)
                                                              .orientation ==
                                                          Orientation.portrait
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.65
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.75,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              child: Stack(
                                                  alignment: Alignment.topRight,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height >
                                                                  550
                                                              ? 60
                                                              : 20),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              Image.network(
                                                                listIconBadge[
                                                                        index]
                                                                    .imagePath,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.35,
                                                              ),
                                                              Container(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.61,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child:
                                                                    SingleChildScrollView(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Container(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              0.4,
                                                                          child: Text(
                                                                              listIconBadge[index].title,
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Container(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.4,
                                                                        child: Text(
                                                                            listIconBadge[index]
                                                                                .description,
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: TextStyle(fontSize: 15)),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Icon(Icons.clear),
                                                    )
                                                  ]))));
                        });
                  },
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Image.network(
                      listIconBadge[index].imagePath,
                      width: MediaQuery.of(context).size.width * 0.14,
                    ),
                  ),
                );
              }),
            )),
        listIconBadge.length > 0
            ? SizedBox(
                height: 10,
              )
            : SizedBox(),
        listIconBadge.length > 0
            ? (listIconBadge.length > 8
                ? GestureDetector(
                    onTap: showAll,
                    child: !showAllBadge
                        ? Icon(
                            Icons.keyboard_arrow_down,
                            color: colorsDropdown,
                          )
                        : Icon(Icons.keyboard_arrow_up, color: colorsDropdown),
                  )
                : SizedBox())
            : SizedBox()
      ],
    );
  }
}
