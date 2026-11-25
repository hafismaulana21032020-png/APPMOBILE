import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';
import '../../data/menu_data.dart';
import '../models/product_model.dart';
import 'menu_service.dart';

/// Service pengelolaan Menu Favorit pengguna (user_favorites di MySQL).
/// Mendukung Optimistic UI Update + Rollback otomatis jika request backend gagal.
class FavoriteService extends ChangeNotifier {
  FavoriteService._();
  static final FavoriteService instance = FavoriteService._();

  final Set<String> _favoriteIds = {};
  final Set<String> _favoriteNormNames = {};
  List<ProductModel> _backendFavorites = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<ProductModel> get backendFavorites => List.unmodifiable(_backendFavorites);

  /// Daftar produk favorit lokal yang dicocokkan agar kaya asset foto & status Sold Out terbaru
  List<ProductModel> get resolvedFavoriteProducts {
    final result = <ProductModel>[];
    final seenNorm = <String>{};

    // Utamakan resolusi dari breakfreeMenuItems agar gambar lokal & varian lengkap
    for (final localItem in breakfreeMenuItems) {
      if (isFavorite(localItem.id, localItem.name)) {
        final norm = MenuService.normalizeName(localItem.name);
        if (!seenNorm.contains(norm)) {
          seenNorm.add(norm);
          result.add(MenuService.instance.resolveProduct(localItem));
        }
      }
    }

    // Tambahkan produk favorit dari backend yang mungkin belum ada di menu_data.dart lokal
    for (final beItem in _backendFavorites) {
      final norm = MenuService.normalizeName(beItem.name);
      if (!seenNorm.contains(norm)) {
        seenNorm.add(norm);
        result.add(MenuService.instance.resolveProduct(beItem));
      }
    }

    return result;
  }

  bool isFavorite(String id, String name) {
    if (_favoriteIds.contains(id)) return true;
    final norm = MenuService.normalizeName(name);
    if (norm.isNotEmpty && _favoriteNormNames.contains(norm)) return true;
    for (final fn in _favoriteNormNames) {
      if (fn.length >= 4 && (norm.contains(fn) || fn.contains(norm))) {
        return true;
      }
    }
    return false;
  }

  void syncFromProductsList(List<ProductModel> products) {
    bool changed = false;
    for (final p in products) {
      final norm = MenuService.normalizeName(p.name);
      if (p.isFavorite) {
        if (!_favoriteIds.contains(p.id) || (norm.isNotEmpty && !_favoriteNormNames.contains(norm))) {
          _favoriteIds.add(p.id);
          if (norm.isNotEmpty) _favoriteNormNames.add(norm);
          changed = true;
        }
      }
    }
    if (changed) notifyListeners();
  }

  Future<void> fetchFavorites() async {
    await Future<void>.delayed(Duration.zero);
    if (!ApiService.instance.hasToken) {
      clear();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService.instance.getFavorites();
      if (res['success'] == true && res['favorites'] is List) {
        final list = res['favorites'] as List;
        final newIds = <String>{};
        final newNorms = <String>{};
        final parsed = <ProductModel>[];

        for (final raw in list) {
          if (raw is Map<String, dynamic>) {
            final p = ProductModel.fromJson(raw).copyWith(isFavorite: true);
            parsed.add(p);
            newIds.add(p.id);
            final norm = MenuService.normalizeName(p.name);
            if (norm.isNotEmpty) newNorms.add(norm);
          }
        }

        _backendFavorites = parsed;
        _favoriteIds
          ..clear()
          ..addAll(newIds);
        _favoriteNormNames
          ..clear()
          ..addAll(newNorms);
      }
    } catch (e) {
      debugPrint('FavoriteService fetchFavorites error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle favorit dengan Optimistic UI Update dan Rollback jika gagal
  Future<Map<String, dynamic>> toggleFavorite(ProductModel product) async {
    if (!ApiService.instance.hasToken) {
      return {
        'success': false,
        'message': 'Silakan masuk ke akun untuk menyimpan menu favorit.',
      };
    }

    final norm = MenuService.normalizeName(product.name);
    final wasFav = isFavorite(product.id, product.name);

    // 1. Optimistic update
    if (wasFav) {
      _favoriteIds.remove(product.id);
      _favoriteNormNames.remove(norm);
      _backendFavorites.removeWhere(
        (p) => p.id == product.id || MenuService.normalizeName(p.name) == norm,
      );
    } else {
      _favoriteIds.add(product.id);
      if (norm.isNotEmpty) _favoriteNormNames.add(norm);
    }
    notifyListeners();

    // 2. Panggil API Backend
    try {
      final res = await ApiService.instance.toggleFavorite(
        productId: product.id,
        productName: product.name,
      );

      if (res['success'] == true) {
        final serverState = res['isFavorite'] == true;
        final backendId = res['productId']?.toString();
        if (serverState && backendId != null) {
          _favoriteIds.add(backendId);
        } else if (!serverState && backendId != null) {
          _favoriteIds.remove(backendId);
        }
        // Sinkronisasi ulang daftar favorit lengkap di latar belakang
        fetchFavorites();
        return res;
      }

      // Rollback jika server menolak
      _rollback(product.id, norm, wasFav);
      return res;
    } catch (e) {
      _rollback(product.id, norm, wasFav);
      return {
        'success': false,
        'message': 'Gagal memperbarui favorit: $e',
      };
    }
  }

  void _rollback(String id, String norm, bool previousState) {
    if (previousState) {
      _favoriteIds.add(id);
      if (norm.isNotEmpty) _favoriteNormNames.add(norm);
    } else {
      _favoriteIds.remove(id);
      _favoriteNormNames.remove(norm);
    }
    notifyListeners();
  }

  void clear() {
    _favoriteIds.clear();
    _favoriteNormNames.clear();
    _backendFavorites = [];
    notifyListeners();
  }
}
