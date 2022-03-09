import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui show Image;

import 'package:flutter/material.dart';

class ImageFileMap {
  ImageFileMap();

  final Map<String, ui.Image> _images = new Map<String, ui.Image>();

  /// Loads a list of images given their urls.
  Future<List<ui.Image>> load(List<String> urls) {
    return Future.wait(urls.map(loadImage));
  }

  /// Loads a single image given the image's [url] and adds it to the [ImageMap].
  Future<ui.Image> loadImage(String url) async {
    final file = File(url);
    ImageStream stream = new FileImage(file).resolve(ImageConfiguration.empty);
    Completer<ui.Image> completer = new Completer<ui.Image>();
    ImageStreamListener listener;
    listener = new ImageStreamListener((ImageInfo frame, bool synchronousCall) {
      final ui.Image image = frame.image;
      _images[url] = image;
      completer.complete(image);
      stream.removeListener(listener);
    });
    stream.addListener(listener);
    return completer.future;
  }

  /// Returns a preloaded image, given its [url].
  ui.Image getImage(String url) => _images[url];

  /// Returns a preloaded image, given its [url].
  ui.Image operator [](String url) => _images[url];
}
