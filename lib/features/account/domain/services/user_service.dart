import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';

class UserService extends ChangeNotifier {
  UserService._();
  static final UserService instance = UserService._();

  String _name = 'HAFIZ MAULANA';
  String _email = 'hafiz.maulana@gmail.com';
  String _phone = '0812 •••• 7890';
  String _birthDate = '18 Mei 2000';
  String _memberBadge = 'Member Gold';
  int _points = 1240;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get birthDate => _birthDate;
  String get memberBadge => _memberBadge;
  int get points => _points;

  void setPoints(int value) {
    _points = value;
    notifyListeners();
  }

  void addPoints(int pointsToAdd) {
    _points += pointsToAdd;
    notifyListeners();
  }

  bool deductPoints(int pointsToDeduct) {
    if (_points >= pointsToDeduct) {
      _points -= pointsToDeduct;
      notifyListeners();
      return true;
    }
    return false;
  }

  String get initials {
    final parts = _name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'HM';
  }

  void updateProfile({
    required String name,
    required String email,
    required String phone,
    required String birthDate,
  }) {
    _name = name;
    _email = email;
    _phone = phone;
    _birthDate = birthDate;
    notifyListeners();

    // Sync secara asinkron ke BreakFree Backend API
    ApiService.instance.updateProfile(
      name: name,
      phone: phone,
      birthDate: birthDate,
    );
  }

  /// Sinkronisasi profil dengan data terbaru dari database backend
  Future<void> syncWithBackend() async {
    try {
      final res = await ApiService.instance.getProfile();
      if (res['success'] == true && res['profile'] != null) {
        final p = res['profile'];
        _name = p['name'] ?? _name;
        _email = p['email'] ?? _email;
        _phone = p['phone'] ?? _phone;
        _birthDate = p['birthDate'] ?? _birthDate;
        _memberBadge = p['memberBadge'] ?? _memberBadge;
        _points = p['points'] ?? _points;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('UserService syncWithBackend error: $e');
    }
  }
}

