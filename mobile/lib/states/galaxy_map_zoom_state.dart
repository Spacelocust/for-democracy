import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class GalaxyMapZoomState with ChangeNotifier {
  double _zoomFactor;

  Vector3? _translation;

  GalaxyMapZoomState({
    required double zoomFactor,
    Vector3? translation,
  }) : _zoomFactor = zoomFactor {
    _translation = translation;
  }

  double get zoomFactor => _zoomFactor;

  Vector3? get translation => _translation;

  void setZoomFactor(double zoomFactor) {
    _zoomFactor = zoomFactor;

    notifyListeners();
  }

  void setTranslation(Vector3 translation) {
    _translation = translation;

    notifyListeners();
  }
}
