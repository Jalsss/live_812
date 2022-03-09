import 'package:flutter/material.dart';

class CounterTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int count;
  final String initialText;
  final FocusNode focusNode;
  final int maxLine;
  final TextInputType keyboardType;

  CounterTextField({
    Key key,
    this.initialText,
    @required this.controller,
    @required this.hintText,
    @required this.count,
    this.maxLine = 3,
    this.focusNode,
    this.keyboardType,
  })
      : super(key: key);

  @override
  _CounterTextFieldState createState() => _CounterTextFieldState();
}

class _CounterTextFieldState extends State<CounterTextField> {
  String _initialText;

  @override
  Widget build(BuildContext context) {
    if (_initialText != widget.initialText) {
      widget.controller.text = widget.initialText;
      _initialText = widget.initialText;
    }
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      decoration: BoxDecoration(
          color: Colors.black.withAlpha(50),
          borderRadius: BorderRadius.all(Radius.circular(6)),
          border: Border.all(color: Colors.white, width: 1)),
      child: TextField(
        focusNode: widget.focusNode,
        style: TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
            counter: Container(
              alignment: Alignment.bottomRight,
              child: Text(
                "${widget.controller.text.length} / ${widget.count}",
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            filled: true,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: widget.hintText,
            labelStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
        maxLines: widget.maxLine,
        controller: widget.controller,
        maxLength: widget.count,
        onChanged: (_) {
          setState(() {});
        },
        keyboardType: widget.keyboardType,
      ),
    );
  }
}
