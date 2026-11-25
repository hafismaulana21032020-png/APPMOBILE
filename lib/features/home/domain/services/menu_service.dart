import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';
import '../../data/menu_data.dart';
import '../models/product_model.dart';
import 'favorite_service.dart';

/// Single source of truth untuk katalog menu dan status ketersediaan (Sold Out / Ready)
/// yang tersinkronisasi langsung dengan Web POS dan Database MySQL melalui backend Express.
class MenuService extends ChangeNotifier {
  MenuService._() {
    _initializeDefaults();
    fetchMenu(force: true);
    startAutoSync();
  }

  static final MenuService instance = MenuService._();

  final Map<String, bool> _availabilityById = {};
  final Map<String, bool> _availabilityByName = {};
  final Set<String> _soldOutIds = {};
  final Set<String> _soldOutNames = {};
  List<ProductModel> _allProducts = List.from(breakfreeMenuItems);
  bool _isLoading = false;
  DateTime? _lastFetched;
  Timer? _autoSyncTimer;

  List<ProductModel> get allProducts => List.unmodifiable(_allProducts);
  bool get isLoading => _isLoading;

  void startAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      fetchMenu(force: true);
    });
  }

  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  /// Normalisasi nama produk untuk toleransi variasi penamaan POS vs Mobile
  static String normalizeName(String name) {
    var s = name.trim().toLowerCase();
    s = s.replaceAll('sf ', '');
    s = s.replaceAll('breakfree ', '');
    s = s.replaceAll('krispi', 'crispy');
    s = s.replaceAll('pau', 'pao');
    s = s.replaceAll('sarijan', '');
    s = s.replaceAll(RegExp(r'\s*\+\s*es\s*teh.*'), '');
    s = s.replaceAll(RegExp(r'\s*\+\s*telur.*'), '');
    s = s.replaceAll(RegExp(r'\s*\([^)]*\)'), '');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  void _initializeDefaults() {
    for (final item in breakfreeMenuItems) {
      _availabilityById[item.id] = true;
      final norm = normalizeName(item.name);
      _availabilityByName[norm] = true;
      _availabilityByName[item.name.trim().toLowerCase()] = true;
    }
  }

  /// Sinkronisasi menu, status Sold Out, dan status favorit dari database backend
  Future<void> fetchMenu({bool force = false}) async {
    if (!force && _lastFetched != null && DateTime.now().difference(_lastFetched!).inSeconds < 3) {
      return;
    }

    _isLoading = true;
    try {
      final res = await ApiService.instance.getProducts();
      if (res['success'] == true && res['products'] is List) {
        final list = res['products'] as List;

        final Set<String> newSoldOutIds = {};
        final Set<String> newSoldOutNames = {};
        final List<ProductModel> parsedList = [];

        for (final raw in list) {
          if (raw is Map<String, dynamic>) {
            final p = ProductModel.fromJson(raw);
            parsedList.add(p);

            final rawId = p.id.toString();
            final rawName = p.name.trim().toLowerCase();
            final norm = normalizeName(p.name);

            _availabilityById[rawId] = p.isAvailable;
            _availabilityByName[rawName] = p.isAvailable;
            _availabilityByName[norm] = p.isAvailable;

            if (!p.isAvailable) {
              newSoldOutIds.add(rawId);
              newSoldOutNames.add(rawName);
              if (norm.isNotEmpty) newSoldOutNames.add(norm);
            }
          }
        }

        if (parsedList.isNotEmpty) {
          FavoriteService.instance.syncFromProductsList(parsedList);
        }

        _soldOutIds.clear();
        _soldOutIds.addAll(newSoldOutIds);

        _soldOutNames.clear();
        _soldOutNames.addAll(newSoldOutNames);

        _allProducts = breakfreeMenuItems.map((localItem) {
          final isAvail = isProductAvailable(localItem);
          final isFav = FavoriteService.instance.isFavorite(localItem.id, localItem.name);
          return localItem.copyWith(isAvailable: isAvail, isFavorite: isFav);
        }).toList();

        _lastFetched = DateTime.now();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('MenuService fetchMenu error: $e');
    } finally {
      _isLoading = false;
    }
  }

  bool isProductAvailable(ProductModel product) {
    if (isSoldOut(product.id, product.name)) {
      return false;
    }
    return product.isAvailable;
  }

  bool isSoldOut(String id, String name) {
    if (_soldOutIds.contains(id)) {
      return true;
    }

    final lower = name.trim().toLowerCase();
    if (_soldOutNames.contains(lower)) {
      return true;
    }

    final norm = normalizeName(name);
    if (norm.isNotEmpty && _soldOutNames.contains(norm)) {
      return true;
    }

    for (final so in _soldOutNames) {
      if (so.length >= 4 && (norm.contains(so) || so.contains(norm))) {
        return true;
      }
    }

    return false;
  }

  /// Ambil model produk dengan status ketersediaan & favorit terbaru
  ProductModel resolveProduct(ProductModel item) {
    return item.copyWith(
      isAvailable: isProductAvailable(item),
      isFavorite: FavoriteService.instance.isFavorite(item.id, item.name),
    );
  }
}
