import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/services/api_service.dart';
import '../../../account/domain/services/user_service.dart';
import '../../../cart/domain/models/cart_item_model.dart';
import '../models/order_model.dart';

/// Service managing Live Order Tracking and Order History for BreakFree.
class OrderService extends ChangeNotifier {
  OrderService._() {
    _initDefaultHistory();
    // Otomatis tarik pesanan aktif terbaru dari database MySQL saat app dibuka
    syncActiveOrderFromBackend();
  }

  static final OrderService instance = OrderService._();

  OrderModel? _activeOrder;
  final List<OrderModel> _orderHistory = [];

  OrderModel? get activeOrder => _activeOrder;
  List<OrderModel> get orderHistory => List.unmodifiable(_orderHistory);

  void _initDefaultHistory() {
    _orderHistory.addAll([
      OrderModel(
        id: '#BF-2849',
        queueNumber: 'A-14',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        status: OrderStatus.selesai,
        totalPrice: 42000,
        paymentMethod: 'QRIS',
        promoCode: 'BREAK20',
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
      ),
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
  Future<OrderModel> createOrderFromCart({
    required List<CartItemModel> items,
    required String paymentMethod,
    required int totalPrice,
    String? promoCode,
    String pickupType = 'Dine-in (Minum di Kafe)',
  }) async {
    final now = DateTime.now();
    final randomNum = (Random().nextInt(9000) + 1000).toString().padLeft(4, '0');
    final queueCode =
        '${['A', 'B', 'C'][Random().nextInt(3)]}-${(Random().nextInt(40) + 1).toString().padLeft(2, '0')}';

    final orderId = '#BF-$randomNum';

    final newOrder = OrderModel(
      id: orderId,
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

    // Kirim pesanan ke backend terpadu secara langsung
    // Pesanan ini otomatis masuk ke antrean dapur Web POS kasir!
    try {
      final res = await ApiService.instance.checkoutOrder({
        'orderId': newOrder.id,
        'queueNumber': newOrder.queueNumber,
        'customerName': UserService.instance.name,
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
      });

      if (res['success'] == true) {
        debugPrint('Pesanan ${newOrder.id} (${newOrder.queueNumber}) berhasil masuk ke Live Tracking Web POS & Dapur!');
      } else {
        debugPrint('Checkout backend status: ${res['message']}');
      }
    } catch (e) {
      debugPrint('Checkout backend sync error: $e');
    }

    return newOrder;
  }

  /// Sinkronisasi status Live Tracking secara real-time dari database backend Express
  /// yang diupdate oleh kasir melalui Web POS.
  Future<void> syncActiveOrderFromBackend() async {
    try {
      // Jika _activeOrder sudah ada dan bukan demo selesai, kita sinkronkan dengan ID tersebut.
      // Jika _activeOrder null atau statusnya selesai, cari order aktif terbaru yang sedang diproses di database
      String? orderIdToQuery;
      if (_activeOrder != null &&
          !_activeOrder!.id.contains('2849') &&
          _activeOrder!.status != OrderStatus.selesai) {
        orderIdToQuery = _activeOrder!.id;
      }

      final res = await ApiService.instance.getActiveOrder(orderIdToQuery);
      if (res['success'] == true && res['activeOrder'] != null) {
        final data = res['activeOrder'];
        final rawStatus = data['status']?.toString().toLowerCase().trim() ?? 'diterima';

        OrderStatus status = OrderStatus.diterima;
        if (rawStatus == 'diproses') {
          status = OrderStatus.diproses;
        } else if (rawStatus == 'siapdiambil' || rawStatus == 'siap diambil' || rawStatus == 'siap') {
          status = OrderStatus.siapDiambil;
        } else if (rawStatus == 'selesai') {
          status = OrderStatus.selesai;
        }

        final now = DateTime.now();
        final updatedTimes = <OrderStatus, DateTime>{
          OrderStatus.diterima: now.subtract(const Duration(minutes: 6)),
        };
        // HANYA buat status timestamp jika backend memang sudah mengubah status ke tahap tersebut:
        if (status == OrderStatus.diproses || status == OrderStatus.siapDiambil || status == OrderStatus.selesai) {
          updatedTimes[OrderStatus.diproses] = now.subtract(const Duration(minutes: 3));
        }
        if (status == OrderStatus.siapDiambil || status == OrderStatus.selesai) {
          updatedTimes[OrderStatus.siapDiambil] = now.subtract(const Duration(minutes: 1));
        }
        if (status == OrderStatus.selesai) {
          updatedTimes[OrderStatus.selesai] = now;
        }

        List<CartItemModel> items = [];
        if (data['items'] != null && data['items'] is List) {
          items = (data['items'] as List).map((it) => CartItemModel(
            id: it['id']?.toString() ?? 'item',
            name: it['name']?.toString() ?? 'Kopi BreakFree',
            options: it['options']?.toString() ?? 'Regular',
            price: (it['price'] as num?)?.toInt() ?? 18000,
            quantity: (it['quantity'] as num?)?.toInt() ?? 1,
            image: (it['image'] != null && it['image'].toString().isNotEmpty)
                ? it['image'].toString()
                : AppAssets.breakfreeArenLatte,
          )).toList();
        }

        final updatedOrder = OrderModel(
          id: data['id']?.toString() ?? _activeOrder?.id ?? '#BF-0000',
          queueNumber: data['queueNumber']?.toString() ?? _activeOrder?.queueNumber ?? 'A-01',
          counterName: data['counterName']?.toString() ?? 'Counter Bar 01',
          pickupType: data['pickupType']?.toString() ?? 'Dine-in (Minum di Kafe)',
          createdAt: data['createdAt'] != null
              ? DateTime.tryParse(data['createdAt'].toString()) ?? now
              : now,
          status: status,
          estimatedMinutes: (data['estimatedMinutes'] as num?)?.toInt() ?? 5,
          baristaName: data['baristaName']?.toString() ?? 'Barista Reza',
          baristaNote: data['baristaNote']?.toString() ?? 'Barista sedang meracik pesanan.',
          totalPrice: (data['totalPrice'] as num?)?.toInt() ?? (_activeOrder?.totalPrice ?? 42000),
          paymentMethod: data['paymentMethod']?.toString() ?? 'QRIS',
          promoCode: data['promoCode']?.toString(),
          statusTimes: updatedTimes,
          items: items.isNotEmpty ? items : (_activeOrder?.items ?? []),
        );

        _activeOrder = updatedOrder;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('OrderService syncActiveOrderFromBackend error: $e');
    }
  }

  /// Manually advances the status of the active order (for live demo / test).
  void advanceStatus() {
    final current = _activeOrder;
    if (current == null) {
      syncActiveOrderFromBackend();
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
        syncActiveOrderFromBackend();
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
