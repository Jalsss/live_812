import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/image_util.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/keyboard_util.dart';
import 'package:live812/utils/widget/counter_textfield.dart';
import 'package:live812/utils/widget/spinning_indicator.dart';

class TimelinePostForm extends StatefulWidget {
  final String timelineId;
  final TextEditingController editingController;
  final String imgUrl;
  final void Function() beforePost;
  final void Function(String text, File image, DateTime date) onPost;
  final void Function() onCancel;

  TimelinePostForm({
    Key key,
    @required this.timelineId,
    this.editingController,
    @required this.imgUrl,
    this.beforePost,
    this.onPost,
    this.onCancel,
  })
      : super(key: key);

  @override
  _TimelinePostFormState createState() => _TimelinePostFormState();
}

class _TimelinePostFormState extends State<TimelinePostForm> {
  TextEditingController _controllerText;
  File _image;
  bool _isPosting = false;
  bool _deleteImage = false;

  @override
  void initState() {
    super.initState();
    _controllerText = widget.editingController ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.editingController == null)
      _controllerText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: ColorLive.C26,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Column(
            children: <Widget>[
              (_image == null && widget.imgUrl == null) || _deleteImage
                  ? Container()
                  : Container(
                      height: 120,
                      width: double.infinity,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10),
                            width: double.infinity,
                            child: _image != null
                                ? Image.file(
                                    _image,
                                    fit: BoxFit.contain,
                                  )
                                : Image.network(
                                    widget.imgUrl,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _image = null;
                                  _deleteImage = true;
                                });
                              },
                              child: SvgPicture.asset(
                                "assets/svg/ic_close.svg",
                                height: 20,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
              SizedBox(height: 8),
              CounterTextField(
                controller: _controllerText,
                hintText: Lang.HINT_TIMELINE,
                count: 300,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    onPressed: _getGalleryImage,
                    child: Row(
                      children: <Widget>[
                        SvgPicture.asset("assets/svg/ic_gallery.svg"),
                        SizedBox(width: 10),
                        Text(
                          "画像を添付",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  widget.onCancel == null ? null : GestureDetector(
                    child: Container(
                      child: Text(
                        Lang.CANCEL,
                        style: TextStyle(color: ColorLive.BLUE),
                      ),
                    ),
                    onTap: () {
                      _controllerText.clear();
                      widget.onCancel();
                    },
                  ),
                  MaterialButton(
                    minWidth: 20,
                    height: 34,
                    onPressed: _isPosting ? null : _postTimeline,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    color: ColorLive.BLUE,
                    child: Text(
                      widget.timelineId == null ? Lang.DO_POST : Lang.DO_EDIT,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ].where((w) => w != null).toList(),
              ),
            ],
          ),
        ),
        !_isPosting ? Container() : SpinningIndicator(),
      ],
    );
  }

  Future _getGalleryImage() async {
    final image = await ImageUtil.pickImage(context, ImageSource.gallery);
    if (image != null) {
      final croppedFile = await ImageUtil.cropImage(image.path);
      if (croppedFile != null) {
        setState(() {
          _image = croppedFile;
          _deleteImage = false;
        });
      }
    }
  }

  Future<void> _postTimeline() async {
    final text = _controllerText.text;
    if (text.isEmpty)
      return;
    if (text.length > 300)
      return;

    if (widget.beforePost != null)
      widget.beforePost();

    KeyboardUtil.close(context);

    final service = BackendService(this.context);

    String base64Image;
    File shrinkedImage;
    if (_image != null) {
      shrinkedImage = await ImageUtil.shrinkIfNeeded(_image, Consts.TIMELINE_IMAGE_WIDTH);
      base64Image = ImageUtil.toBase64DataImage(shrinkedImage);
    }
    setState(() => _isPosting = true);
    final response = await service.postTimeline(
        text, base64Image: base64Image, timelineId: widget.timelineId);
    setState(() => _isPosting = false);
    if (response?.result == true) {
      setState(() {
        _image = null;
        _controllerText.clear();
      });
      widget.onPost(text, shrinkedImage, DateTime.now());
    } else {
      showNetworkErrorDialog(this.context, msg: response?.getByKey('msg'));
    }
  }
}
