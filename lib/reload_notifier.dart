import 'package:flutter/material.dart';

class ReloadNotifier extends ChangeNotifier {
  void reload() {
    notifyListeners();
  }
}