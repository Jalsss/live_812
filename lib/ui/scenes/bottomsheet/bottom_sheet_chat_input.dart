import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/custom_validator.dart';
import 'dart:async';

class BottomSheetChatInput extends StatefulWidget {
  final TextEditingController controller;
  final void Function() onBackMenu;
  final void Function(String text, bool ng) onSend;
  final bool isLiver;

  BottomSheetChatInput({@required this.controller, @required final this.isLiver, @required this.onBackMenu, @required this.onSend});

  @override
  _BottomSheetChatInputState createState() => _BottomSheetChatInputState();
}

class _BottomSheetChatInputState extends State<BottomSheetChatInput> {
  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();

  bool _hasSpeech = false;
  bool _speechButtonEnable = true;
  bool _isSpeechMode = false;
  SpeechToText _speech;
  Timer _speechAnimationTimer;
  int _speechAnimationCount = 0;

  @override
  void dispose() {
    _disposeSpeech();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            bottom: _isSpeechMode ? 0 : mq.padding.bottom + mq.viewInsets.bottom,
            left: max(mq.padding.left, 18.0),
            right: max(mq.padding.right, 18.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MaterialButton(
                minWidth: 50,
                padding: EdgeInsets.symmetric(horizontal: 2),
                onPressed: () {
                  widget.onBackMenu();
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Text(
                      Lang.BACK_MENU,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Form(
                        key: _formKey,
                        autovalidate: true,
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: <Widget>[
                            TextFormField(
                              keyboardType: TextInputType.text,
                              autofocus: true,
                              enabled: !_isSpeechMode,
                              validator: CustomValidator.validateChatMessage,
                              controller: widget.controller,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                fillColor: ColorLive.TRANS_90,
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.white)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.white)),
                                //labelText: Lang.SEARCH_HINT,
                                hintText: widget.isLiver ? Lang.CHAT_HINT_LIVER : Lang.CHAT_HINT,
                                labelStyle: TextStyle(color: Colors.white),
                                hintStyle: TextStyle(
                                    color: Colors.grey[600], fontSize: 13),
                                contentPadding: EdgeInsets.only(left: 10, top: 6, right: 40, bottom: 6,),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.mic,
                                color: Colors.grey,
                              ),
                              onPressed: !_speechButtonEnable ? null : () {
                                _startListening();
                              }),
                          ].where((w) => w != null).toList(),
                        ),
                      ),
                    ),
                  ),
                  MaterialButton(
                    minWidth: 20,
                    onPressed: () {
                      _validateMessage();
                    },
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: ColorLive.BORDER2),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    color: ColorLive.PINK,
                    child: Text(
                      Lang.SEND,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        !_isSpeechMode ? null : Container(
          color: Colors.black,
          width: double.infinity,
          margin: EdgeInsets.only(top: 4),
          padding: EdgeInsets.only(top: 10, bottom: mq.padding.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.mic, color: Colors.lightBlue),
                  iconSize: 100,
                  onPressed: null,
              ),
              Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Text(
                  "・",
                  style: TextStyle(
                      fontSize: 16,
                      color: _speechAnimationCount > 0
                          ? Colors.lightBlue
                          : Colors.white),
                ),
                Text(
                  "・",
                  style: TextStyle(
                      fontSize: 16,
                      color: _speechAnimationCount > 1
                          ? Colors.lightBlue
                          : Colors.white),
                ),
                Text(
                  "・",
                  style: TextStyle(
                      fontSize: 16,
                      color: _speechAnimationCount > 2
                          ? Colors.lightBlue
                          : Colors.white),
                ),
              ]),
              SizedBox(height: 40),
              GestureDetector(
                child: Container(
                  child: Text(
                    Lang.CANCEL,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onTap: () {
                  _stopListening();
                },
              ),
            ],
          ),
        ),
      ].where((w) => w != null).toList(),
    );
  }

  void _validateMessage() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      final text = widget.controller.text;
      if (text.length > 0) {
        // NG判定はサーバに任せる
        widget.onSend(widget.controller.text, false);
      }
    }
  }

  //------------ Voice Recognition ------------
  void _startListening() async {
    if (_isSpeechMode || !_speechButtonEnable)
      return;

    final hasSpeech = await _initSpeech();
    if (!hasSpeech) {
      // TODO: エラーダイアログを表示
      await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('音声認識が無効です'),
            content: Text('本体の設定から音声認識の権限を有効にしてください'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
      await _disposeSpeech();
      return;
    }

    setState(() => _isSpeechMode = true);
    await _speech.listen(onResult: _resultListener);
    _speechAnimationTimer = Timer.periodic(Duration(milliseconds: 100), _animationCount);
  }

  void _animationCount(Timer _) async {
    var count = _speechAnimationCount;
    count++;
    if (count > 3) {
      count = 0;
    }
    setState(() {
      _speechAnimationCount = count;
    });
  }

  Future<void> _stopListening() async {
    await _disposeSpeech();
  }

  Future<void> _cancelListening() async {
    await _disposeSpeech(cancel: true);
  }

  Future<bool> _initSpeech() async {
    if (_speech == null) {
      _speech = SpeechToText();
      setState(() => _speechButtonEnable = false);
      bool hasSpeech = await _speech.initialize(onError: _errorListener);
      if (!mounted)
        return false;
      setState(() {
        _speechButtonEnable = true;
        _hasSpeech = hasSpeech;
      });
    }
    return _hasSpeech;
  }

  Future<void> _disposeSpeech({bool cancel = false}) async {
    if (_speech == null)
      return;

    _speechAnimationTimer?.cancel();
    _speechAnimationTimer = null;
    if (mounted) {
      setState(() {
        _isSpeechMode = false;
        _speechAnimationCount = 0;
      });
    }

    if (cancel)
      await _speech.cancel();
    else
      await _speech.stop();
    _speech = null;
  }

  void _resultListener(SpeechRecognitionResult result) {
    final text = result.recognizedWords;
    if (text.length > 0) {
      widget.controller.text = text;
    }
    if (result.finalResult) {
      _stopListening();
    }
  }

  void _errorListener(SpeechRecognitionError error) {
    _cancelListening();
  }
}
