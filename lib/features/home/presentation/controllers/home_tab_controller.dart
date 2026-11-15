import 'package:flutter/foundation.dart';

/// Tracks the active bottom-bar tab for [HomePage] so transitions know slide direction.
class HomeTabController extends ChangeNotifier {
  HomeTabController._();
  static final HomeTabController instance = HomeTabController._();

  int _currentIndex = 0;
  int _previousIndex = 0;

  int get currentIndex => _currentIndex;
  int get previousIndex => _previousIndex;

  /// Updates the active tab index (`0` = Home, `1` = Menu) and notifies listeners.
  void selectTab(int index) {
    if (index == _currentIndex) return;
    _previousIndex = _currentIndex;
    _currentIndex = index;
    notifyListeners();
  }

  /// Resets active tab silently or with notification back to Home (`0`).
  void resetToHome() {
    if (_currentIndex == 0) return;
    _previousIndex = _currentIndex;
    _currentIndex = 0;
    notifyListeners();
  }
}

