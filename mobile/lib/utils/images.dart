import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String imageBasePath = 'assets/images/';

Future<ui.Image> loadImage(String imageName) async {
  final data = await rootBundle.load("$imageBasePath$imageName");

  return decodeImageFromList(data.buffer.asUint8List());
}
