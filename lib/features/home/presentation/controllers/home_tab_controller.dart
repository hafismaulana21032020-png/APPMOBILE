import 'package:flutter/foundation.dart';

/// Tracks the active bottom-bar tab for [HomePage] so transitions know slide direction.
class HomeTabController extends ChangeNotifier {
  HomeTabController._();
  static final HomeTabController instance = HomeTabController._();

  int _currentIndex = 0;
  int _previousIndex = 0;
  String _selectedCategory = 'Semua';

  int get currentIndex => _currentIndex;
  int get previousIndex => _previousIndex;
  String get selectedCategory => _selectedCategory;

  /// Updates the active tab index (`0` = Home, `1` = Menu) and optionally changes category.
  void selectTab(int index, {String? category}) {
    if (category != null) {
      _selectedCategory = category;
    }
    if (index == _currentIndex && category == null) return;
    _previousIndex = _currentIndex;
    _currentIndex = index;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
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

