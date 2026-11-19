import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Service API Client untuk menghubungkan Flutter APPMOBILE
/// langsung ke Backend Express terpadu (breakfree-backend).
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  /// URL Base API Backend Express (Port default: 5000)
  /// - Android Emulator: 10.0.2.2:5000
  /// - Web / Windows / Mac: localhost:5000
  /// - Device Fisik: Ubah ke IP komputer lokal (misal: 192.168.1.X:5000)
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api/v1/mobile';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000/api/v1/mobile';
    return 'http://localhost:5000/api/v1/mobile';
  }

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
    return _put('/profile/me', {
      'name': name,
      if (phone != null) 'phone': phone,
      if (birthDate != null) 'birthDate': birthDate,
    });
  }

  Future<Map<String, dynamic>> getPointsHistory() async {
    return _get('/profile/points');
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

  Future<Map<String, dynamic>> getActiveOrder() async {
    return _get('/orders/active');
  }

  Future<Map<String, dynamic>> getOrderHistory() async {
    return _get('/orders/history');
  }

  Future<Map<String, dynamic>> trackOrder(String orderId) async {
    final cleanId = Uri.encodeComponent(orderId);
    return _get('/orders/$cleanId/track');
  }

  // ===========================================================================
  // 6. AI BARISTA CHATBOT
  // ===========================================================================

  Future<Map<String, dynamic>> sendAiChatMessage(String message) async {
    return _post('/ai-chat/message', {
      'message': message,
    });
  }

  // ===========================================================================
  // HELPER HTTP REQUESTS (Standard Dart HttpClient)
  // ===========================================================================

  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final client = HttpClient();
      final request = await client.getUrl(uri);

      _attachHeaders(request);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('ApiService GET Error [$path]: $e');
      return {'success': false, 'message': 'Gagal terhubung ke backend: $e'};
    }
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final client = HttpClient();
      final request = await client.postUrl(uri);

      _attachHeaders(request);
      request.headers.set('content-type', 'application/json; charset=UTF-8');
      request.write(jsonEncode(data));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('ApiService POST Error [$path]: $e');
      return {'success': false, 'message': 'Gagal terhubung ke backend: $e'};
    }
  }

  Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final client = HttpClient();
      final request = await client.putUrl(uri);

      _attachHeaders(request);
      request.headers.set('content-type', 'application/json; charset=UTF-8');
      request.write(jsonEncode(data));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close();

      return jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('ApiService PUT Error [$path]: $e');
      return {'success': false, 'message': 'Gagal terhubung ke backend: $e'};
    }
  }

  void _attachHeaders(HttpClientRequest request) {
    if (_authToken != null && _authToken!.isNotEmpty) {
      request.headers.set('authorization', 'Bearer $_authToken');
    }
    request.headers.set('accept', 'application/json');
  }
}
