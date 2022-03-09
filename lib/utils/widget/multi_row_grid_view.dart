import 'dart:math';

import 'package:flutter/material.dart';

// GridViewは高さがアスペクト比で与える必要があるため、
// 子要素の高さで自動的に調節できるようにする。
// 内部的にはListViewを使用する。
// 複数の要素を返して、複数の行を指定できるようにする。
class MultiRowGridView extends StatelessWidget {
  final List<List<Widget>> children;
  final EdgeInsetsGeometry padding;
  final int crossAxisCount;

  MultiRowGridView({
    @required this.children,
    this.padding,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    int nchild = children[0].length;
    int nrow = (children.length + crossAxisCount - 1) ~/ crossAxisCount;
    final rows = List.generate(nchild, (i) {
      return children.map((child) => child[i]).toList();
    });
    final List<List<Widget>> list = List.generate(nrow, (i) {
      int n = crossAxisCount;
      int start = i * n;
      int end = min(start + n, children.length);
      final list = rows.map((row) => row.sublist(start, end)).toList();
      if (list.length < n)
        list.add(List.generate(n - list.length, (_) => Container()));
      return list;
    }).expand((x) => x).toList();

    return ListView(
      padding: padding,
      children: list.map((row) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: row.map((cell) => Expanded(
          child: cell,
        )).toList(),
      )).toList(),
    );
  }
}
