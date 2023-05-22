import 'package:flutter/material.dart';

class BackgroundProvider extends ChangeNotifier {
  ImageProvider? _backgroundImage;

  ImageProvider? get backgroundImage => _backgroundImage;

  void updateBackgroundImage(ImageProvider newBackground) {
    _backgroundImage = newBackground;
    notifyListeners();
  }
}