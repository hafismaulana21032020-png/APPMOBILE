import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service API Client untuk menghubungkan Flutter APPMOBILE
/// langsung ke Backend Express terpadu (breakfree-backend).
/// Mendukung semua platform: Web (Chrome), Android Emulator/Fisik, dan Windows Desktop.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static String? customBaseUrl;

  /// URL Base API Backend Express (Port default: 5000)
  /// - Web / Windows Desktop: http://localhost:5000/api/v1/mobile
  /// - Android Emulator: http://10.0.2.2:5000/api/v1/mobile
  /// - Android Device Fisik / Jaringan LAN: http://192.168.68.104:5000/api/v1/mobile
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

  void setAuthToken(String? token) {
    _authToken = token;
  }

  // ===========================================================================
  // 1. AUTHENTICATION (REGISTER, LOGIN, FORGOT PASSWORD)
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
  }) async {
    return _post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return _post('/auth/forgot-password', {
      'email': email,
    });
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    return _post('/auth/reset-password', {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    });
  }

  // ===========================================================================
  // 2. PROFILE & CASHBACK POINTS
  // ===========================================================================

  Future<Map<String, dynamic>> getProfile() async {
    return _get('/profile/me');
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? phone,
    String? birthDate,
  }) async {
    final payload = <String, dynamic>{'name': name};
    if (phone != null) payload['phone'] = phone;
    if (birthDate != null) payload['birthDate'] = birthDate;
    return _put('/profile/me', payload);
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
  // 3. PRODUCTS & CATALOG
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

  // ===========================================================================
  // 4. PROMO / VOUCHER CHECKOUT
  // ===========================================================================

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

  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 6));
      final body = utf8.decode(response.bodyBytes);
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('ApiService GET Error [$path]: $e');
      if (defaultTargetPlatform == TargetPlatform.android &&
          customBaseUrl == null &&
          baseUrl.contains('10.0.2.2')) {
        try {
          final fallbackUri = Uri.parse('$androidFallbackUrl$path');
          final response = await http
              .get(fallbackUri, headers: _buildHeaders())
              .timeout(const Duration(seconds: 6));
          customBaseUrl = androidFallbackUrl;
          final body = utf8.decode(response.bodyBytes);
          return jsonDecode(body) as Map<String, dynamic>;
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
      return jsonDecode(body) as Map<String, dynamic>;
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
          return jsonDecode(body) as Map<String, dynamic>;
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
      return jsonDecode(body) as Map<String, dynamic>;
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
          return jsonDecode(body) as Map<String, dynamic>;
        } catch (_) {}
      }
      return {'success': false, 'message': 'Gagal terhubung ke backend: $e'};
    }
  }
}
