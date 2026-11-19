import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/services/api_service.dart';
import '../../../cart/domain/models/cart_item_model.dart';
import '../models/order_model.dart';

/// Service managing Live Order Tracking and Order History for BreakFree.
class OrderService extends ChangeNotifier {
  OrderService._() {
    _initDefaultOrder();
  }

  static final OrderService instance = OrderService._();

  OrderModel? _activeOrder;
  final List<OrderModel> _orderHistory = [];

  OrderModel? get activeOrder => _activeOrder;
  List<OrderModel> get orderHistory => List.unmodifiable(_orderHistory);

  void _initDefaultOrder() {
    final now = DateTime.now();
    _activeOrder = OrderModel(
      id: '#BF-2849',
      queueNumber: 'A-14',
      counterName: 'Counter Bar 01',
      pickupType: 'Dine-in (Minum di Kafe)',
      createdAt: now.subtract(const Duration(minutes: 4)),
      status: OrderStatus.diproses,
      estimatedMinutes: 6,
      baristaName: 'Barista Reza',
      baristaNote:
          'Espresso baru selesai diekstrak, sedang menuang susu segar creamy.',
      totalPrice: 42000,
      paymentMethod: 'QRIS',
      promoCode: 'BREAK20',
      statusTimes: {
        OrderStatus.diterima: now.subtract(const Duration(minutes: 4)),
        OrderStatus.diproses: now.subtract(const Duration(minutes: 2)),
      },
      items: [
        CartItemModel(
          id: 'demo-item-1',
          name: 'Breakfree Aren Latte',
          options: 'Ice Coffee • Less Sugar • Oatmilk',
          price: 25000,
          quantity: 1,
          image: AppAssets.breakfreeArenLatte,
        ),
        CartItemModel(
          id: 'demo-item-2',
          name: 'French Fries',
          options: 'Snack • Saus Sambal & Mayo',
          price: 17000,
          quantity: 1,
          image: AppAssets.coffeeBanner,
        ),
      ],
    );

    _orderHistory.addAll([
      OrderModel(
        id: '#BF-0302',
        queueNumber: 'B-08',
        createdAt: DateTime(2025, 6, 28, 19, 41),
        status: OrderStatus.selesai,
        totalPrice: 45000,
        paymentMethod: 'QRIS',
        items: [
          CartItemModel(
            id: 'h-1',
            name: 'Breakfree Aren Latte',
            options: 'Ice Coffee • Regular',
            price: 18000,
            quantity: 1,
            image: AppAssets.breakfreeArenLatte,
          ),
          CartItemModel(
            id: 'h-2',
            name: 'Croissant Almond',
            options: 'Pastry • Original Butter',
            price: 27000,
            quantity: 1,
            image: AppAssets.coffeeBanner,
          ),
        ],
      ),
      OrderModel(
        id: '#BF-0297',
        queueNumber: 'A-22',
        createdAt: DateTime(2025, 6, 21, 12, 36),
        status: OrderStatus.selesai,
        totalPrice: 62000,
        paymentMethod: 'E-Wallet',
        items: [
          CartItemModel(
            id: 'h-3',
            name: '2 Ice Kopi Susu',
            options: 'Bundle Berdua',
            price: 28000,
            quantity: 1,
            image: AppAssets.breakfreeArenLatte,
          ),
          CartItemModel(
            id: 'h-4',
            name: 'Indomie Nyemek',
            options: 'Makanan • Telur Setengah Matang',
            price: 16000,
            quantity: 2,
            image: AppAssets.nasiGorengTelur,
          ),
        ],
      ),
      OrderModel(
        id: '#BF-0259',
        queueNumber: 'A-05',
        createdAt: DateTime(2025, 5, 15, 11, 6),
        status: OrderStatus.selesai,
        totalPrice: 18000,
        paymentMethod: 'Tunai',
        items: [
          CartItemModel(
            id: 'h-5',
            name: 'Signature Matcha',
            options: 'Non-Kopi • Less Sugar',
            price: 18000,
            quantity: 1,
            image: AppAssets.cubeTiramisu,
          ),
        ],
      ),
    ]);
  }

  /// Creates a new live order when user checks out from the cart.
  OrderModel createOrderFromCart({
    required List<CartItemModel> items,
    required String paymentMethod,
    required int totalPrice,
    String? promoCode,
    String pickupType = 'Dine-in (Minum di Kafe)',
  }) {
    final now = DateTime.now();
    final randomNum = (Random().nextInt(9000) + 1000).toString().padLeft(4, '0');
    final queueCode =
        '${['A', 'B', 'C'][Random().nextInt(3)]}-${(Random().nextInt(40) + 1).toString().padLeft(2, '0')}';

    final newOrder = OrderModel(
      id: '#BF-$randomNum',
      queueNumber: queueCode,
      counterName: 'Counter Bar 01',
      pickupType: pickupType,
      createdAt: now,
      status: OrderStatus.diterima,
      estimatedMinutes: items.length > 2 ? 12 : 8,
      baristaName: 'Barista Reza',
      baristaNote:
          'Pesanan telah diterima kasir & dapur. Segera masuk proses peracikan.',
      totalPrice: totalPrice,
      paymentMethod: paymentMethod,
      promoCode: promoCode,
      items: List.from(items),
      statusTimes: {
        OrderStatus.diterima: now,
      },
    );

    _activeOrder = newOrder;
    notifyListeners();

    // Kirim pesanan ke backend terpadu secara asinkron
    ApiService.instance.checkoutOrder({
      'items': items.map((it) => {
        'id': it.id,
        'name': it.name,
        'options': it.options,
        'price': it.price,
        'quantity': it.quantity,
        'image': it.image,
      }).toList(),
      'pickupType': pickupType,
      'paymentMethod': paymentMethod,
      'promoCode': promoCode,
      'totalPrice': totalPrice,
    }).catchError((e) {
      debugPrint('Checkout backend sync error: $e');
    });

    return newOrder;
  }

  /// Manually advances the status of the active order (for live demo / test).
  void advanceStatus() {
    final current = _activeOrder;
    if (current == null) {
      _initDefaultOrder();
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    final updatedTimes = Map<OrderStatus, DateTime>.from(current.statusTimes);

    switch (current.status) {
      case OrderStatus.diterima:
        updatedTimes[OrderStatus.diproses] = now;
        _activeOrder = current.copyWith(
          status: OrderStatus.diproses,
          estimatedMinutes: 5,
          baristaNote:
              'Barista sedang meracik minuman & memasak hidanganmu di bar.',
          statusTimes: updatedTimes,
        );
        break;

      case OrderStatus.diproses:
        updatedTimes[OrderStatus.siapDiambil] = now;
        _activeOrder = current.copyWith(
          status: OrderStatus.siapDiambil,
          estimatedMinutes: 0,
          baristaNote:
              'Pesananmu sudah siap di ${current.counterName}! Tunjukkan nomor ${current.id} atau antrean ${current.queueNumber}.',
          statusTimes: updatedTimes,
        );
        break;

      case OrderStatus.siapDiambil:
        updatedTimes[OrderStatus.selesai] = now;
        final finished = current.copyWith(
          status: OrderStatus.selesai,
          estimatedMinutes: 0,
          baristaNote:
              'Pesanan telah diambil oleh pelanggan. Selamat menikmati jeda santaimu di BreakFree!',
          statusTimes: updatedTimes,
        );
        _orderHistory.insert(0, finished);
        _activeOrder = finished;
        break;

      case OrderStatus.selesai:
        // Reset to in-progress demo order
        _initDefaultOrder();
        break;
    }

    notifyListeners();
  }

  /// Resets the active order back to initial 'diterima' state.
  void resetToNewOrder() {
    final now = DateTime.now();
    final order = _activeOrder ??
        OrderModel(
          id: '#BF-2849',
          queueNumber: 'A-14',
          createdAt: now,
          status: OrderStatus.diterima,
          items: const [],
          totalPrice: 25000,
          paymentMethod: 'QRIS',
        );

    _activeOrder = order.copyWith(
      status: OrderStatus.diterima,
      estimatedMinutes: 10,
      baristaNote: 'Pesanan baru saja dikonfirmasi & masuk ke dapur barista.',
      statusTimes: {OrderStatus.diterima: now},
    );
    notifyListeners();
  }
}
