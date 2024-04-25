
import 'package:flutter/material.dart';

class Language with ChangeNotifier {
  bool _isFrench = true;

  bool get isFrench => _isFrench;

  void toggleLanguage() {
    _isFrench = !_isFrench;
    notifyListeners();
  }
}
