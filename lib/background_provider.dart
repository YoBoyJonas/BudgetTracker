import 'package:flutter/material.dart';

class BackgroundProvider extends ChangeNotifier {
  ImageProvider? _backgroundImage;
  Color? _widgetColor;
  bool? _soundOption;

  ImageProvider? get backgroundImage => _backgroundImage;
  Color? get widgetColor => _widgetColor;
  bool? get soundOption => _soundOption;

  void updateBackgroundImage(ImageProvider newBackground) {
    _backgroundImage = newBackground;
    notifyListeners();
  }

  void updateWidgetColor(Color newColor) {
    _widgetColor = newColor;
    notifyListeners();
  }

  void updateSound(bool sound) {
    _soundOption = sound;
    notifyListeners();
  }
}