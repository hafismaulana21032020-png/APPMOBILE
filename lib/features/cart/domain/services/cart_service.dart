import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../home/domain/models/product_model.dart';
import '../models/cart_item_model.dart';

class CartService extends ChangeNotifier {
  CartService._();
  static final CartService instance = CartService._();

  // Daftar item keranjang (default awal sesuai desain)
  final List<CartItemModel> _items = [
    CartItemModel(
      id: 'default-1',
      name: 'Kopi Susu Gula Aren',
      options: 'Regular, Normal Sugar, Oatmilk',
      price: 25000,
      quantity: 1,
      image: AppAssets.breakfreeArenLatte,
    ),
    CartItemModel(
      id: 'default-2',
      name: 'Croissant Almond',
      options: 'Original Butter pastry',
      price: 26000,
      quantity: 1,
      image: AppAssets.coffeeBanner,
    ),
  ];

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get totalItemCount =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addProduct(
    ProductModel product, {
    String? options,
    int? customPrice,
  }) {
    final itemPrice = customPrice ?? product.price;
    final itemOptions =
        options ?? product.tag ?? (product.subcategory ?? 'Regular');
    final itemId = '${product.id}_$itemOptions';

    final existingIndex = _items.indexWhere((item) => item.id == itemId);
    if (existingIndex != -1) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(
        CartItemModel(
          id: itemId,
          name: product.name,
          options: itemOptions,
          price: itemPrice,
          quantity: 1,
          image: product.image.isNotEmpty
              ? product.image
              : AppAssets.breakfreeArenLatte,
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

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

