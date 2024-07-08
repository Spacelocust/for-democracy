import 'package:flutter/material.dart';

class GalaxyMapZoomState with ChangeNotifier {
  double _zoomFactor;

  GalaxyMapZoomState({
    required double zoomFactor,
  }) : _zoomFactor = zoomFactor;

  double get zoomFactor => _zoomFactor;

  void setZoomFactor(double zoomFactor) {
    _zoomFactor = zoomFactor;

    notifyListeners();
  }
}
