import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';

class UserService extends ChangeNotifier {
  UserService._();
  static final UserService instance = UserService._();

  int? _id;
  String _name = '';
  String _email = '';
  String? _phone;
  String? _birthDate;
  String? _avatarUrl;
  bool _hasPassword = true;
  String _memberBadge = 'Member BreakFree';
  int _points = 0;

  int? get id => _id;
  String get name => _name;
  String get email => _email;
  String? get phone => (_phone != null && _phone!.trim().isNotEmpty) ? _phone!.trim() : null;
  String? get birthDate =>
      (_birthDate != null && _birthDate!.trim().isNotEmpty) ? _birthDate!.trim() : null;
  String? get avatarUrl =>
      (_avatarUrl != null && _avatarUrl!.trim().isNotEmpty) ? _avatarUrl!.trim() : null;
  bool get hasPassword => _hasPassword;
  String get memberBadge => _memberBadge;
  int get points => _points;
  bool get isLoggedIn => ApiService.instance.hasToken && _email.isNotEmpty;

  void setFromJson(Map<String, dynamic> data) {
    _id = (data['id'] as num?)?.toInt() ?? _id;
    _name = data['name']?.toString() ?? _name;
    _email = data['email']?.toString() ?? _email;

    if (data.containsKey('phone')) {
      final rawPhone = data['phone']?.toString().trim();
      _phone = (rawPhone == null || rawPhone.isEmpty || rawPhone == '0812 •••• 7890')
          ? null
          : rawPhone;
    }

    if (data.containsKey('birthDate') || data.containsKey('birth_date')) {
      final rawBirth = (data['birthDate'] ?? data['birth_date'])?.toString().trim();
      _birthDate = (rawBirth == null || rawBirth.isEmpty || rawBirth == '18 Mei 2000')
          ? null
          : rawBirth;
    }

    if (data.containsKey('avatarUrl') || data.containsKey('avatar_url')) {
      final rawAvatar = (data['avatarUrl'] ?? data['avatar_url'])?.toString().trim();
      _avatarUrl = (rawAvatar == null || rawAvatar.isEmpty) ? null : rawAvatar;
    }

    if (data.containsKey('hasPassword')) {
      _hasPassword = data['hasPassword'] == true;
    }

    _memberBadge = data['memberBadge']?.toString() ??
        data['member_badge']?.toString() ??
        'Member BreakFree';
    _points = (data['points'] as num?)?.toInt() ?? _points;
    notifyListeners();
  }

  void clear() {
    _id = null;
    _name = '';
    _email = '';
    _phone = null;
    _birthDate = null;
    _avatarUrl = null;
    _hasPassword = true;
    _memberBadge = 'Member BreakFree';
    _points = 0;
    notifyListeners();
  }

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
    final trimmed = _name.trim();
    if (trimmed.isEmpty) return 'BF';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'BF';
  }

  Future<Map<String, dynamic>> updateProfileAsync({
    required String name,
    String? phone,
    String? birthDate,
    String? currentPassword,
  }) async {
    final res = await ApiService.instance.updateProfile(
      name: name,
      phone: phone ?? '',
      birthDate: birthDate ?? '',
      currentPassword: currentPassword,
    );

    if (res['success'] == true && res['profile'] is Map<String, dynamic>) {
      setFromJson(res['profile'] as Map<String, dynamic>);
    } else if (res['success'] == true) {
      _name = name.trim().toUpperCase();
      _phone = (phone != null && phone.trim().isNotEmpty) ? phone.trim() : null;
      _birthDate = (birthDate != null && birthDate.trim().isNotEmpty) ? birthDate.trim() : null;
      notifyListeners();
    }
    return res;
  }

  /// Sinkronisasi profil dengan data terbaru dari database MySQL backend
  Future<bool> syncWithBackend() async {
    if (!ApiService.instance.hasToken) return false;
    try {
      final res = await ApiService.instance.getProfile();
      if (res['success'] == true && res['profile'] is Map<String, dynamic>) {
        setFromJson(res['profile'] as Map<String, dynamic>);
        return true;
      }
      final authMe = await ApiService.instance.getAuthMe();
      if (authMe['success'] == true && authMe['user'] is Map<String, dynamic>) {
        setFromJson(authMe['user'] as Map<String, dynamic>);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('UserService syncWithBackend error: $e');
      return false;
    }
  }
}
