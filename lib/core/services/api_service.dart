import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service API Client untuk menghubungkan Flutter APPMOBILE
/// langsung ke Backend Express terpadu (breakfree-backend).
/// Mendukung semua platform: Web (Chrome), Android Emulator/Fisik, dan Windows Desktop.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static const String _tokenPrefsKey = 'breakfree_auth_token';
  static String? customBaseUrl;

  /// URL Base API Backend Express (Port default: 5000)
  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }
    if (kIsWeb) {
      return 'http://localhost:5000/api/v1/mobile';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api/v1/mobile';
    }
    return 'http://localhost:5000/api/v1/mobile';
  }

  static const String androidFallbackUrl = 'http://192.168.68.104:5000/api/v1/mobile';

  String? _authToken;
  String? get authToken => _authToken;
  bool get hasToken => _authToken != null && _authToken!.isNotEmpty;

  Future<void> loadSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_tokenPrefsKey);
      if (saved != null && saved.isNotEmpty) {
        _authToken = saved;
      }
    } catch (e) {
      debugPrint('ApiService loadSavedToken error: $e');
    }
  }

  Future<void> setAuthToken(String? token) async {
    _authToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (token == null || token.isEmpty) {
        await prefs.remove(_tokenPrefsKey);
      } else {
        await prefs.setString(_tokenPrefsKey, token);
      }
    } catch (e) {
      debugPrint('ApiService setAuthToken error: $e');
    }
  }

  Future<void> clearSession() async {
    await setAuthToken(null);
  }

  // ===========================================================================
  // 1. AUTHENTICATION (REGISTER, LOGIN, GOOGLE SIGN-IN, FORGOT PASSWORD)
  // ===========================================================================

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return _post('/auth/login', {
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
    };
    if (phone != null && phone.trim().isNotEmpty) {
      payload['phone'] = phone.trim();
    }
    return _post('/auth/register', payload);
  }

  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    return _post('/auth/google', {
      'idToken': idToken,
    });
  }

  Future<Map<String, dynamic>> getAuthMe() async {
    return _get('/auth/me');
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return _post(
      '/auth/forgot-password',
      {'email': email},
      timeoutDuration: const Duration(seconds: 30),
    );
  }

  Future<Map<String, dynamic>> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    return _post('/auth/verify-otp', {
      'email': email,
      'otp': otp,
    });
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    bool allowSimilar = false,
  }) async {
    return _post('/auth/reset-password', {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
      'allowSimilar': allowSimilar,
    });
  }

  // ===========================================================================
  // 2. PROFILE, NOTIFICATIONS, & CASHBACK POINTS
  // ===========================================================================

  Future<Map<String, dynamic>> getProfile() async {
    return _get('/profile/me');
  }

  Future<Map<String, dynamic>> verifyCurrentPassword(
    String currentPassword,
  ) async {
    return _post('/profile/verify-password', {
      'currentPassword': currentPassword,
    });
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? birthDate,
    String? avatarUrl,
    String? currentPassword,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (phone != null) {
      payload['phone'] = phone.trim().isEmpty ? null : phone.trim();
    }
    if (birthDate != null) {
      payload['birthDate'] = birthDate.trim().isEmpty ? null : birthDate.trim();
    }
    if (avatarUrl != null) payload['avatarUrl'] = avatarUrl;
    if (currentPassword != null && currentPassword.isNotEmpty) {
      payload['currentPassword'] = currentPassword;
    }
    return _put('/profile/me', payload);
  }

  Future<Map<String, dynamic>> changePassword({
    String? currentPassword,
    required String newPassword,
    bool allowSimilar = false,
  }) async {
    final payload = <String, dynamic>{
      'newPassword': newPassword,
      'allowSimilar': allowSimilar,
    };
    if (currentPassword != null) {
      payload['currentPassword'] = currentPassword;
    }
    return _put('/profile/password', payload);
  }

  Future<Map<String, dynamic>> getNotifications() async {
    return _get('/profile/notifications');
  }

  Future<Map<String, dynamic>> getPointsHistory() async {
    return _get('/profile/points');
  }

  Future<Map<String, dynamic>> getMyPoints([String? type]) async {
    final queryStr = (type != null && type.isNotEmpty && type != 'Semua')
        ? '?type=$type'
        : '';
    return _get('/points/me$queryStr');
  }

  Future<Map<String, dynamic>> previewPoints(int subtotal) async {
    return _post('/points/preview', {'subtotal': subtotal});
  }

  // ===========================================================================
  // 3. PRODUCTS, CATALOG, & FAVORITES
  // ===========================================================================

  Future<Map<String, dynamic>> getProducts({
    String? category,
    String? subcategory,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (category != null && category != 'Semua') queryParams['category'] = category;
    if (subcategory != null && subcategory != 'Semua') queryParams['subcategory'] = subcategory;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final queryStr = queryParams.isEmpty
        ? ''
        : '?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';

    return _get('/products$queryStr');
  }

  Future<Map<String, dynamic>> getCategories() async {
    return _get('/products/categories');
  }

  Future<Map<String, dynamic>> getFavorites() async {
    return _get('/favorites');
  }

  Future<Map<String, dynamic>> toggleFavorite({
    required String productId,
    String? productName,
  }) async {
    return _post('/favorites/toggle', {
      'productId': productId,
      if (productName != null && productName.isNotEmpty) 'productName': productName,
    });
  }

  // ===========================================================================
  // 4. PROMO / VOUCHER CHECKOUT
  // ===========================================================================

  Future<Map<String, dynamic>> getActivePromos() async {
    return _get('/promos/active');
  }

  Future<Map<String, dynamic>> validatePromo({
    required String code,
    required int subtotal,
  }) async {
    return _post('/promos/validate', {
      'code': code,
      'subtotal': subtotal,
    });
  }

  // ===========================================================================
  // 5. ORDERS & LIVE TRACKING
  // ===========================================================================

  Future<Map<String, dynamic>> checkoutOrder(Map<String, dynamic> orderPayload) async {
    return _post('/orders/checkout', orderPayload);
  }

  Future<Map<String, dynamic>> getActiveOrder([String? orderId]) async {
    final queryStr = (orderId != null && orderId.isNotEmpty)
        ? '?orderId=${Uri.encodeComponent(orderId)}'
        : '';
    return _get('/orders/active$queryStr');
  }

  Future<Map<String, dynamic>> getOrderHistory() async {
    return _get('/orders/history');
  }

  Future<Map<String, dynamic>> trackOrder(String orderId) async {
    final cleanId = Uri.encodeComponent(orderId);
    return _get('/orders/$cleanId/track');
  }

  Future<Map<String, dynamic>> checkMidtransPaymentStatus(String orderId) async {
    final cleanId = Uri.encodeComponent(orderId);
    return _get('/payments/midtrans/status/$cleanId');
  }

  // ===========================================================================
  // 6. AI BARISTA CHATBOT (GEMINI API & RECOMMENDATIONS)
  // ===========================================================================

  Future<Map<String, dynamic>> chatWithBarista({
    required String message,
    List<Map<String, String>> history = const [],
  }) async {
    return _post(
      '/ai-chat/chat',
      {
        'message': message,
        'history': history,
      },
      timeoutDuration: const Duration(seconds: 45),
    );
  }

  Future<Map<String, dynamic>> getBaristaRecommendations() async {
    return _get('/ai-chat/recommendations');
  }

  Future<Map<String, dynamic>> sendAiChatMessage(String message) async {
    return chatWithBarista(message: message);
  }

  // ===========================================================================
  // HELPER HTTP REQUESTS (Cross-platform package:http)
  // ===========================================================================

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Map<String, dynamic> _decodeJsonResponse(String body, int statusCode) {
    if (body.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Respons server kosong (HTTP $statusCode).',
      };
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return {
      'success': false,
      'message': 'Format respons server tidak valid.',
    };
  }

  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 8));
      final body = utf8.decode(response.bodyBytes);
      return _decodeJsonResponse(body, response.statusCode);
    } catch (e) {
      debugPrint('ApiService GET Error [$path]: $e');
      if (defaultTargetPlatform == TargetPlatform.android &&
          customBaseUrl == null &&
          baseUrl.contains('10.0.2.2')) {
        try {
          final fallbackUri = Uri.parse('$androidFallbackUrl$path');
          final response = await http
              .get(fallbackUri, headers: _buildHeaders())
              .timeout(const Duration(seconds: 8));
          customBaseUrl = androidFallbackUrl;
          final body = utf8.decode(response.bodyBytes);
          return _decodeJsonResponse(body, response.statusCode);
        } catch (_) {}
      }
      return {'success': false, 'message': 'Gagal terhubung ke backend: $e'};
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> data, {
    Duration timeoutDuration = const Duration(seconds: 15),
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http
          .post(uri, headers: _buildHeaders(), body: jsonEncode(data))
          .timeout(timeoutDuration);
      final body = utf8.decode(response.bodyBytes);
      return _decodeJsonResponse(body, response.statusCode);
    } catch (e) {
      debugPrint('ApiService POST Error [$path]: $e');
      if (defaultTargetPlatform == TargetPlatform.android &&
          customBaseUrl == null &&
          baseUrl.contains('10.0.2.2')) {
        try {
          final fallbackUri = Uri.parse('$androidFallbackUrl$path');
          final response = await http
              .post(fallbackUri, headers: _buildHeaders(), body: jsonEncode(data))
              .timeout(timeoutDuration);
          customBaseUrl = androidFallbackUrl;
          final body = utf8.decode(response.bodyBytes);
          return _decodeJsonResponse(body, response.statusCode);
        } catch (_) {}
      }
      return {'success': false, 'message': 'Gagal terhubung ke backend: $e'};
    }
  }

  Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http
          .put(uri, headers: _buildHeaders(), body: jsonEncode(data))
          .timeout(const Duration(seconds: 8));
      final body = utf8.decode(response.bodyBytes);
      return _decodeJsonResponse(body, response.statusCode);
    } catch (e) {
      debugPrint('ApiService PUT Error [$path]: $e');
      if (defaultTargetPlatform == TargetPlatform.android &&
          customBaseUrl == null &&
          baseUrl.contains('10.0.2.2')) {
        try {
          final fallbackUri = Uri.parse('$androidFallbackUrl$path');
          final response = await http
              .put(fallbackUri, headers: _buildHeaders(), body: jsonEncode(data))
              .timeout(const Duration(seconds: 8));
          customBaseUrl = androidFallbackUrl;
          final body = utf8.decode(response.bodyBytes);
          return _decodeJsonResponse(body, response.statusCode);
        } catch (_) {}
      }
      return {'success': false, 'message': 'Gagal terhubung ke backend: $e'};
    }
  }
}
