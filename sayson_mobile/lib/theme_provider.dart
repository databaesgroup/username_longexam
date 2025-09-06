import 'package:flutter/material.dart';
import 'constants.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  ThemeData get theme => _isDark ? buildDarkTheme() : buildLightTheme();

  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
