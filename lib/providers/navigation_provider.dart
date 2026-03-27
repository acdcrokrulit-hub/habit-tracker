import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void goHome() {
    _selectedIndex = 0;
    notifyListeners();
  }

  void goCalendar() {
    _selectedIndex = 1;
    notifyListeners();
  }

  void goStats() {
    _selectedIndex = 2;
    notifyListeners();
  }

  void goProfile() {
    _selectedIndex = 3;
    notifyListeners();
  }
}
