import 'package:flutter/material.dart';

class AppModeProvider extends ChangeNotifier {
  bool _isPreviewMode = false;

  bool get isPreviewMode => _isPreviewMode;

  void setPreviewMode(bool value) {
    if (_isPreviewMode == value) return;
    _isPreviewMode = value;
    notifyListeners();
  }

  void reset() {
    _isPreviewMode = false;
    notifyListeners();
  }
}
