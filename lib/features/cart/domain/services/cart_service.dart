import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../home/domain/models/product_model.dart';
import '../models/cart_item_model.dart';

class CartService extends ChangeNotifier {
  CartService._();
  static final CartService instance = CartService._();

  // Daftar item keranjang (kosong saat pertama kali dibuka)
  final List<CartItemModel> _items = [];

  String? _appliedPromoCode;
  String? get appliedPromoCode => _appliedPromoCode;

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get totalItemCount =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  void applyPromoCode(String? code) {
    final normalized = code?.trim().toUpperCase();
    _appliedPromoCode = (normalized == null || normalized.isEmpty)
        ? null
        : normalized;
    notifyListeners();
  }

  void addProduct(
    ProductModel product, {
    String? options,
    int? customPrice,
    int quantity = 1,
    String? note,
  }) {
    final itemPrice = customPrice ?? product.price;
    final baseOptions =
        options ?? product.tag ?? (product.subcategory ?? 'Regular');
    final cleanNote = note?.trim();
    final hasNote = cleanNote != null && cleanNote.isNotEmpty;
    final itemOptions =
        hasNote ? '$baseOptions (Catatan: $cleanNote)' : baseOptions;
    final itemId = '${product.id}_$itemOptions';

    final qtyToAdd = quantity > 0 ? quantity : 1;
    final existingIndex = _items.indexWhere((item) => item.id == itemId);
    if (existingIndex != -1) {
      _items[existingIndex].quantity += qtyToAdd;
    } else {
      _items.add(
        CartItemModel(
          id: itemId,
          name: product.name,
          options: itemOptions,
          price: itemPrice,
          quantity: qtyToAdd,
          image: product.image.isNotEmpty
              ? product.image
              : AppAssets.breakfreeArenLatte,
          note: cleanNote,
        ),
      );
    }
    notifyListeners();
  }

  void increment(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrement(int index) {
    if (index >= 0 && index < _items.length) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        notifyListeners();
      }
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void removeById(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    _appliedPromoCode = null;
    notifyListeners();
  }
}

