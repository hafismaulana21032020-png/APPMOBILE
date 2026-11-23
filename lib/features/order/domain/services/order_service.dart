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
    // Tarik status pesanan aktif & riwayat nyata langsung dari database MySQL backend
    syncActiveOrderFromBackend();
    loadHistoryFromBackend();
  }

  static final OrderService instance = OrderService._();

  OrderModel? _activeOrder;
  final List<OrderModel> _orderHistory = [];

  OrderModel? get activeOrder => _activeOrder;
  List<OrderModel> get orderHistory => List.unmodifiable(_orderHistory);

  /// Creates a new live order when user checks out from the cart.
  Future<OrderModel> createOrderFromCart({
    required List<CartItemModel> items,
    required String paymentMethod,
    required int totalPrice,
    String? promoCode,
    String pickupType = 'Dine-in (Minum di Kafe)',
    bool usePoints = false,
  }) async {
    final now = DateTime.now();
    final randomNum = (Random().nextInt(9000) + 1000).toString().padLeft(4, '0');
    final queueCode =
        '${['A', 'B', 'C'][Random().nextInt(3)]}-${(Random().nextInt(40) + 1).toString().padLeft(2, '0')}';

    final orderId = '#BF-$randomNum';

    final isCash = paymentMethod.toLowerCase().contains('cash') || paymentMethod.toLowerCase().contains('tunai');
    final initialStatus = isCash ? OrderStatus.menungguPembayaran : OrderStatus.diterima;
    final initialBaristaNote = isCash
        ? 'Menunggu pembayaran tunai di kasir. Silakan bayar ke kasir agar pesanan segera diracik.'
        : 'Pesanan telah diterima kasir & dapur. Segera masuk proses peracikan.';

    var newOrder = OrderModel(
      id: orderId,
      queueNumber: queueCode,
      counterName: 'Counter Bar 01',
      pickupType: pickupType,
      createdAt: now,
      status: initialStatus,
      estimatedMinutes: isCash ? 10 : (items.length > 2 ? 12 : 8),
      baristaName: 'Barista Reza',
      baristaNote: initialBaristaNote,
      totalPrice: totalPrice,
      paymentMethod: paymentMethod,
      promoCode: promoCode,
      items: List.from(items),
      statusTimes: {
        initialStatus: now,
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
        'usePoints': usePoints,
      });

      if (res['success'] == true) {
        debugPrint('Pesanan ${newOrder.id} (${newOrder.queueNumber}) berhasil masuk ke Live Tracking Web POS & Dapur!');
        if (res['points'] != null) {
          final pointsData = Map<String, dynamic>.from(res['points']);
          newOrder = newOrder.copyWith(points: pointsData);
          _activeOrder = newOrder;
          notifyListeners();
        }
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
      String? orderIdToQuery;
      if (_activeOrder != null && _activeOrder!.status != OrderStatus.selesai) {
        orderIdToQuery = _activeOrder!.id;
      }

      final res = await ApiService.instance.getActiveOrder(orderIdToQuery);
      if (res['success'] == true && res['activeOrder'] != null) {
        final data = res['activeOrder'];
        final rawStatus = data['status']?.toString().toLowerCase().trim() ?? 'diterima';

        OrderStatus status = OrderStatus.diterima;
        if (rawStatus == 'menunggupembayaran' || rawStatus == 'menunggu pembayaran' || rawStatus == 'menunggu bayar') {
          status = OrderStatus.menungguPembayaran;
        } else if (rawStatus == 'diproses') {
          status = OrderStatus.diproses;
        } else if (rawStatus == 'siapdiambil' || rawStatus == 'siap diambil' || rawStatus == 'siap') {
          status = OrderStatus.siapDiambil;
        } else if (rawStatus == 'selesai') {
          status = OrderStatus.selesai;
        }

        final now = DateTime.now();
        final updatedTimes = <OrderStatus, DateTime>{};
        if (status == OrderStatus.menungguPembayaran) {
          updatedTimes[OrderStatus.menungguPembayaran] = now;
        } else {
          updatedTimes[OrderStatus.diterima] = now.subtract(const Duration(minutes: 6));
          if (status == OrderStatus.diproses || status == OrderStatus.siapDiambil || status == OrderStatus.selesai) {
            updatedTimes[OrderStatus.diproses] = now.subtract(const Duration(minutes: 3));
          }
          if (status == OrderStatus.siapDiambil || status == OrderStatus.selesai) {
            updatedTimes[OrderStatus.siapDiambil] = now.subtract(const Duration(minutes: 1));
          }
          if (status == OrderStatus.selesai) {
            updatedTimes[OrderStatus.selesai] = now;
          }
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
          totalPrice: (data['totalPrice'] as num?)?.toInt() ?? (_activeOrder?.totalPrice ?? 0),
          paymentMethod: data['paymentMethod']?.toString() ?? 'QRIS',
          promoCode: data['promoCode']?.toString(),
          statusTimes: updatedTimes,
          items: items.isNotEmpty ? items : (_activeOrder?.items ?? []),
        );

        _activeOrder = updatedOrder;
        notifyListeners();
      } else if (res['success'] == true && res['hasActiveOrder'] == false) {
        // Jika tidak ada pesanan aktif di database:
        if (_activeOrder != null) {
          if (_activeOrder!.status == OrderStatus.selesai &&
              !_orderHistory.any((o) => o.id == _activeOrder!.id)) {
            _orderHistory.insert(0, _activeOrder!);
          }
          _activeOrder = null;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('OrderService syncActiveOrderFromBackend error: $e');
    }
  }

  /// Memuat riwayat pesanan riil dari backend MySQL
  Future<void> loadHistoryFromBackend() async {
    try {
      final res = await ApiService.instance.getOrderHistory();
      if (res['success'] == true && res['orders'] != null) {
        final list = res['orders'] as List;
        _orderHistory.clear();
        for (final o in list) {
          List<CartItemModel> items = [];
          if (o['items'] != null && o['items'] is List) {
            items = (o['items'] as List).map((it) => CartItemModel(
              id: it['id']?.toString() ?? 'item',
              name: it['name']?.toString() ?? 'Kopi BreakFree',
              options: it['options']?.toString() ?? 'Regular',
              price: (it['price'] as num?)?.toInt() ?? 0,
              quantity: (it['quantity'] as num?)?.toInt() ?? 1,
              image: AppAssets.breakfreeArenLatte,
            )).toList();
          }

          _orderHistory.add(OrderModel(
            id: o['id']?.toString() ?? '#BF-0000',
            queueNumber: o['queueNumber']?.toString() ?? '-',
            counterName: o['counterName']?.toString() ?? 'Counter Bar 01',
            pickupType: o['pickupType']?.toString() ?? 'Dine-in (Minum di Kafe)',
            createdAt: o['createdAt'] != null
                ? DateTime.tryParse(o['createdAt'].toString()) ?? DateTime.now()
                : DateTime.now(),
            status: OrderStatus.selesai,
            totalPrice: (o['totalPrice'] as num?)?.toInt() ?? 0,
            paymentMethod: o['paymentMethod']?.toString() ?? 'QRIS',
            items: items,
          ));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('loadHistoryFromBackend error: $e');
    }
  }

  /// Reset / hapus active order lokal
  void clearActiveOrder() {
    _activeOrder = null;
    notifyListeners();
  }
}
