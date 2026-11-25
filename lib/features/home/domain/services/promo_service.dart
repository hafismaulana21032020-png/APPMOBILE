import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';
import '../models/promo_model.dart';

/// Service penyedia promo & voucher aktif yang tersinkronisasi langsung dengan Web POS.
class PromoService extends ChangeNotifier {
  PromoService._();
  static final PromoService instance = PromoService._();

  List<PromoModel> _activePromos = [];
  bool _isLoading = false;
  DateTime? _lastFetched;

  List<PromoModel> get activePromos => List.unmodifiable(_activePromos);
  bool get isLoading => _isLoading;

  /// Promo utama untuk banner & voucher card di Home
  PromoModel? get primaryPromo => _activePromos.isNotEmpty ? _activePromos.first : null;

  /// Memuat daftar promo aktif dari backend Express
  Future<void> fetchActivePromos({bool force = false}) async {
    if (!force && _lastFetched != null && DateTime.now().difference(_lastFetched!).inSeconds < 10) {
      return;
    }

    _isLoading = true;
    await Future<void>.delayed(Duration.zero);
    if (_isLoading) notifyListeners();

    try {
      final res = await ApiService.instance.getActivePromos();
      if (res['success'] == true && res['promos'] is List) {
        final list = res['promos'] as List;
        _activePromos = list
            .whereType<Map<String, dynamic>>()
            .map((e) => PromoModel.fromJson(e))
            .where((p) => p.isActive)
            .toList();

        _lastFetched = DateTime.now();
      }
    } catch (e) {
      debugPrint('PromoService fetchActivePromos error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Validasi kode voucher ke backend secara server-side
  Future<Map<String, dynamic>> validateCode(String code, int subtotal) async {
    try {
      return await ApiService.instance.validatePromo(code: code.trim(), subtotal: subtotal);
    } catch (e) {
      return {
        'success': false,
        'valid': false,
        'message': 'Gagal memvalidasi kode promo: $e',
      };
    }
  }
}
