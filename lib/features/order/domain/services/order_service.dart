import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/services/api_service.dart';
import '../../../account/domain/services/notification_service.dart';
import '../../../account/domain/services/user_service.dart';
import '../../../cart/domain/models/cart_item_model.dart';
import '../../../home/domain/services/pickup_mode_service.dart';
import '../models/order_model.dart';

/// Service managing Live Order Tracking and Order History for BreakFree.
class OrderService extends ChangeNotifier {
  OrderService._() {
    syncActiveOrderFromBackend();
    loadHistoryFromBackend();
  }

  static final OrderService instance = OrderService._();

  OrderModel? _activeOrder;
  final List<OrderModel> _orderHistory = [];

  OrderModel? get activeOrder => _activeOrder;
  List<OrderModel> get orderHistory => List.unmodifiable(_orderHistory);

  int _toInt(dynamic val, [int fallback = 0]) {
    if (val is int) return val;
    if (val is num) return val.round();
    if (val is String) {
      final parsed = double.tryParse(val.trim());
      if (parsed != null) return parsed.round();
    }
    return fallback;
  }

  DateTime? _parseDateLocal(dynamic raw) {
    if (raw == null) return null;
    final parsed = DateTime.tryParse(raw.toString());
    return parsed?.toLocal();
  }

  OrderStatus _parseStatus(dynamic rawStatus) {
    final s = (rawStatus ?? '').toString().toLowerCase().trim();
    if (s == 'cancelled' ||
        s == 'canceled' ||
        s == 'dibatalkan' ||
        s == 'void' ||
        s == 'batal') {
      return OrderStatus.dibatalkan;
    }
    if (s == 'menunggupembayaran' ||
        s == 'menunggu pembayaran' ||
        s == 'menunggu bayar' ||
        s == 'pending') {
      return OrderStatus.menungguPembayaran;
    }
    if (s == 'diproses' || s == 'preparing' || s == 'processing') {
      return OrderStatus.diproses;
    }
    if (s == 'siapdiambil' || s == 'siap diambil' || s == 'siap' || s == 'ready') {
      return OrderStatus.siapDiambil;
    }
    if (s == 'selesai' || s == 'completed' || s == 'done') {
      return OrderStatus.selesai;
    }
    return OrderStatus.diterima;
  }

  OrderModel _parseOrderFromJson(Map<String, dynamic> data, {OrderModel? fallback}) {
    final status = _parseStatus(data['status']);
    final createdAt = _parseDateLocal(data['createdAt']) ??
        fallback?.createdAt ??
        DateTime.now();
    final updatedAt = _parseDateLocal(data['updatedAt']) ?? DateTime.now();

    final updatedTimes = <OrderStatus, DateTime>{};
    if (status == OrderStatus.menungguPembayaran) {
      updatedTimes[OrderStatus.menungguPembayaran] = createdAt;
    } else if (status == OrderStatus.dibatalkan) {
      updatedTimes[OrderStatus.dibatalkan] = updatedAt;
    } else {
      updatedTimes[OrderStatus.diterima] = createdAt;
      if (status == OrderStatus.diproses ||
          status == OrderStatus.siapDiambil ||
          status == OrderStatus.selesai) {
        updatedTimes[OrderStatus.diproses] = updatedAt;
      }
      if (status == OrderStatus.siapDiambil || status == OrderStatus.selesai) {
        updatedTimes[OrderStatus.siapDiambil] = updatedAt;
      }
      if (status == OrderStatus.selesai) {
        updatedTimes[OrderStatus.selesai] = updatedAt;
      }
    }

    List<CartItemModel> items = [];
    if (data['items'] != null && data['items'] is List) {
      items = (data['items'] as List).whereType<Map>().map((rawIt) {
        final it = Map<String, dynamic>.from(rawIt);
        final rawImg = it['image']?.toString() ?? '';
        return CartItemModel(
          id: it['id']?.toString() ?? 'item',
          name: (it['productName'] ?? it['name'] ?? 'Menu BreakFree').toString(),
          options: it['options']?.toString() ?? 'Regular',
          price: _toInt(it['price'], 0),
          quantity: _toInt(it['quantity'], 1),
          image: rawImg.isNotEmpty ? rawImg : AppAssets.breakfreeArenLatte,
        );
      }).toList();
    }

    final rawCashier = data['cashierName']?.toString().trim();
    final rawBarista = data['baristaName']?.toString().trim();
    final rawCancelReason = data['cancelReason']?.toString().trim();

    String resolvedBaristaName = 'Tim Barista BreakFree';
    if (rawCashier != null && rawCashier.isNotEmpty) {
      resolvedBaristaName = rawCashier;
    } else if (rawBarista != null &&
        rawBarista.isNotEmpty &&
        rawBarista != 'Barista Reza') {
      resolvedBaristaName = rawBarista;
    }

    final rawPromo = (data['voucherCode'] ?? data['promoCode'])?.toString().trim();
    final resolvedPromo =
        (rawPromo != null && rawPromo.isNotEmpty) ? rawPromo : null;

    final rawOrderType = (data['orderType'] ?? '').toString().trim().toUpperCase();
    final resolvedOrderType = rawOrderType.isNotEmpty
        ? rawOrderType
        : ((data['pickupType']?.toString().toLowerCase().contains('takeaway') ?? false)
            ? 'TAKEAWAY'
            : (fallback?.orderType ?? 'DINE_IN'));

    final fallbackItems = fallback?.items ?? const <CartItemModel>[];
    final resolvedItems = items.isNotEmpty ? items : fallbackItems;
    final parsedSubtotal = _toInt(data['subtotal'], 0);
    final computedSubtotal = parsedSubtotal > 0
        ? parsedSubtotal
        : resolvedItems.fold<int>(0, (sum, it) => sum + (it.price * it.quantity));

    final voucherDiscount = _toInt(data['voucherDiscount'] ?? data['discountAmount'], 0);
    final discountAmount = _toInt(data['discountAmount'], voucherDiscount);
    final pointsUsed = _toInt(data['pointsUsed'], 0);
    final pointsDiscount = _toInt(data['pointsDiscount'], 0);
    final pointsEarned = _toInt(data['pointsEarned'], 0);
    final taxAmount = _toInt(data['taxAmount'], 0);
    final totalPrice = _toInt(
      data['totalPrice'] ?? data['total'],
      fallback?.totalPrice ?? 0,
    );

    return OrderModel(
      id: (data['id'] ?? data['orderNumber'] ?? fallback?.id ?? '#BF-0000').toString(),
      queueNumber: (data['queueNumber'] ?? fallback?.queueNumber ?? 'A-01').toString(),
      counterName: data['counterName']?.toString() ?? 'Counter Bar 01',
      orderType: resolvedOrderType,
      pickupType: data['pickupType']?.toString() ??
          (resolvedOrderType == 'TAKEAWAY'
              ? 'Takeaway (Bungkus Bawa Pulang)'
              : 'Dine-in (Minum di Kafe)'),
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status,
      estimatedMinutes: _toInt(data['estimatedMinutes'], 8),
      cashierName: (rawCashier != null && rawCashier.isNotEmpty) ? rawCashier : null,
      cancelReason:
          (rawCancelReason != null && rawCancelReason.isNotEmpty) ? rawCancelReason : null,
      baristaName: resolvedBaristaName,
      baristaNote: data['baristaNote']?.toString() ??
          (status == OrderStatus.dibatalkan
              ? 'Pesanan ini dibatalkan oleh kasir BreakFree.'
              : 'Pesanan sedang diproses oleh tim BreakFree.'),
      subtotal: computedSubtotal,
      discountAmount: discountAmount,
      voucherCode: resolvedPromo,
      voucherDiscount: voucherDiscount,
      pointsUsed: pointsUsed,
      pointsDiscount: pointsDiscount,
      pointsEarned: pointsEarned,
      taxAmount: taxAmount,
      totalPrice: totalPrice,
      paymentMethod: data['paymentMethod']?.toString() ?? 'QRIS',
      paymentStatus: data['paymentStatus']?.toString(),
      paymentChannel: data['paymentChannel']?.toString(),
      midtransOrderId:
          data['midtransOrderId']?.toString() ?? fallback?.midtransOrderId,
      snapToken: data['snapToken']?.toString() ?? fallback?.snapToken,
      snapRedirectUrl:
          data['snapRedirectUrl']?.toString() ?? fallback?.snapRedirectUrl,
      promoCode: resolvedPromo,
      statusTimes: updatedTimes,
      items: resolvedItems,
    );
  }

  /// Creates a new live order when user checks out from the cart.
  Future<OrderModel> createOrderFromCart({
    required List<CartItemModel> items,
    required String paymentMethod,
    required int totalPrice,
    String? promoCode,
    String? orderType,
    String? pickupType,
    bool usePoints = false,
  }) async {
    final now = DateTime.now();
    final randomNum = (Random().nextInt(9000) + 1000).toString().padLeft(4, '0');
    final queueCode =
        '${['A', 'B', 'C'][Random().nextInt(3)]}-${(Random().nextInt(40) + 1).toString().padLeft(2, '0')}';

    final orderId = '#BF-$randomNum';
    final resolvedOrderType = (orderType != null && orderType.isNotEmpty)
        ? orderType
        : PickupModeService.instance.mode.code;
    final resolvedPickupType = (pickupType != null && pickupType.isNotEmpty)
        ? pickupType
        : PickupModeService.instance.mode.checkoutDescription;

    final isCash = paymentMethod.toLowerCase().contains('cash') ||
        paymentMethod.toLowerCase().contains('tunai');
    const initialStatus = OrderStatus.menungguPembayaran;
    final initialBaristaNote = isCash
        ? 'Menunggu pembayaran tunai di kasir. Silakan bayar ke kasir agar pesanan segera diracik.'
        : 'Menunggu penyelesaian pembayaran melalui Midtrans.';

    final subtotal = items.fold<int>(0, (sum, it) => sum + (it.price * it.quantity));

    var newOrder = OrderModel(
      id: orderId,
      queueNumber: queueCode,
      counterName: 'Counter Bar 01',
      orderType: resolvedOrderType,
      pickupType: resolvedPickupType,
      createdAt: now,
      status: initialStatus,
      estimatedMinutes: isCash ? 10 : (items.length > 2 ? 12 : 8),
      baristaName: 'Tim Barista BreakFree',
      baristaNote: initialBaristaNote,
      subtotal: subtotal,
      totalPrice: totalPrice,
      paymentMethod: paymentMethod,
      promoCode: promoCode,
      voucherCode: promoCode,
      items: List.from(items),
      statusTimes: {
        initialStatus: now,
      },
    );

    _activeOrder = newOrder;
    notifyListeners();

    try {
      final res = await ApiService.instance.checkoutOrder({
        'orderId': newOrder.id,
        'queueNumber': newOrder.queueNumber,
        'customerName': UserService.instance.name,
        'items': items
            .map((it) => {
                  'id': it.id,
                  'name': it.name,
                  'options': it.options,
                  'price': it.price,
                  'quantity': it.quantity,
                  'image': it.image,
                })
            .toList(),
        'orderType': resolvedOrderType,
        'pickupType': resolvedPickupType,
        'paymentMethod': paymentMethod,
        'promoCode': promoCode,
        'totalPrice': totalPrice,
        'usePoints': usePoints,
      });

      if (res['success'] == true) {
        if (res['order'] is Map<String, dynamic>) {
          newOrder = _parseOrderFromJson(
            Map<String, dynamic>.from(res['order'] as Map),
            fallback: newOrder,
          );
        }
        if (res['payment'] is Map) {
          final payData = Map<String, dynamic>.from(res['payment'] as Map);
          newOrder = newOrder.copyWith(
            midtransOrderId: payData['midtransOrderId']?.toString(),
            snapToken: payData['token']?.toString(),
            snapRedirectUrl: payData['redirectUrl']?.toString(),
            paymentStatus: 'PENDING',
          );
        }
        if (res['points'] != null && res['points'] is Map) {
          final pointsData = Map<String, dynamic>.from(res['points'] as Map);
          newOrder = newOrder.copyWith(points: pointsData);
        }
        _activeOrder = newOrder;
        notifyListeners();
        syncActiveOrderFromBackend();
        NotificationService.instance.fetchNotifications();
      } else {
        final errorMsg =
            res['message']?.toString() ?? 'Gagal membuat pesanan di backend.';
        debugPrint('Checkout backend status: $errorMsg');
        _activeOrder = null;
        notifyListeners();
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Checkout backend sync error: $e');
      rethrow;
    }

    return newOrder;
  }

  /// Sinkronisasi status Live Tracking secara real-time dari database backend Express
  /// yang diupdate oleh kasir melalui Web POS.
  Future<void> syncActiveOrderFromBackend() async {
    if (!ApiService.instance.hasToken) return;
    try {
      String? orderIdToQuery;
      if (_activeOrder != null && !_activeOrder!.status.isTerminal) {
        orderIdToQuery = _activeOrder!.id;
      }

      final previousStatus = _activeOrder?.status;
      final res = await ApiService.instance.getActiveOrder(orderIdToQuery);
      if (res['success'] == true && res['activeOrder'] != null) {
        final data = Map<String, dynamic>.from(res['activeOrder'] as Map);
        final updatedOrder = _parseOrderFromJson(data, fallback: _activeOrder);

        // Jika pengguna baru saja melihat pesanan dibatalkan yang sudah tidak aktif dan
        // backend mengembalikan order aktif yang sama (sudah terminal), tetap pertahankan;
        // jika order baru muncul, ganti dengan order baru.
        _activeOrder = updatedOrder;
        notifyListeners();

        if (previousStatus != null &&
            !previousStatus.isTerminal &&
            updatedOrder.status.isTerminal) {
          UserService.instance.syncWithBackend();
          loadHistoryFromBackend();
          NotificationService.instance.fetchNotifications();
        }
      } else if (res['success'] == true && res['hasActiveOrder'] == false) {
        if (_activeOrder != null && _activeOrder!.status == OrderStatus.dibatalkan) {
          // Biarkan banner Pesanan Dibatalkan tetap terlihat sampai pengguna menutupnya
          return;
        }

        if (_activeOrder != null) {
          final trackedId = _activeOrder!.id;
          await loadHistoryFromBackend();
          await UserService.instance.syncWithBackend();
          await NotificationService.instance.fetchNotifications();

          final matchedIdx = _orderHistory.indexWhere((o) => o.id == trackedId);
          if (matchedIdx != -1 &&
              _orderHistory[matchedIdx].status == OrderStatus.dibatalkan) {
            _activeOrder = _orderHistory[matchedIdx];
            notifyListeners();
            return;
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
    if (!ApiService.instance.hasToken) return;
    try {
      final res = await ApiService.instance.getOrderHistory();
      if (res['success'] == true && res['orders'] is List) {
        final list = res['orders'] as List;
        _orderHistory.clear();
        for (final raw in list) {
          if (raw is Map) {
            _orderHistory.add(
              _parseOrderFromJson(Map<String, dynamic>.from(raw)),
            );
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('loadHistoryFromBackend error: $e');
    }
  }

  /// Mengecek & menyinkronkan status pembayaran Midtrans ke backend Express
  Future<Map<String, dynamic>> checkMidtransStatus(String orderId) async {
    try {
      final res = await ApiService.instance.checkMidtransPaymentStatus(orderId);
      if (res['success'] == true) {
        await syncActiveOrderFromBackend();
        if (res['isPaid'] == true || res['isFailed'] == true) {
          await UserService.instance.syncWithBackend();
          await loadHistoryFromBackend();
          await NotificationService.instance.fetchNotifications();
        }
      }
      return res;
    } catch (e) {
      debugPrint('checkMidtransStatus error: $e');
      return {
        'success': false,
        'message': 'Gagal memeriksa status Midtrans: $e',
      };
    }
  }

  /// Reset / hapus active order lokal
  void clearActiveOrder() {
    _activeOrder = null;
    notifyListeners();
  }

  /// Hapus seluruh state order lokal saat logout
  void clearAll() {
    _activeOrder = null;
    _orderHistory.clear();
    notifyListeners();
  }
}
