import 'package:flutter/material.dart';

class GalaxyMapZoom with ChangeNotifier {
  double _zoomFactor;

  GalaxyMapZoom({
    required double zoomFactor,
  }) : _zoomFactor = zoomFactor;

  double get zoomFactor => _zoomFactor;

  void setZoomFactor(double zoomFactor) {
    _zoomFactor = zoomFactor;

    notifyListeners();
  }
}
