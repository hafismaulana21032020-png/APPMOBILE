import 'package:flutter/material.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../cart/domain/models/cart_item_model.dart';

/// Status live tracking pesanan BreakFree.
enum OrderStatus {
  menungguPembayaran(
    stepIndex: -1,
    title: 'Menunggu Pembayaran',
    subtitle: 'Silakan lakukan pembayaran tunai di kasir',
    badgeText: 'Belum Bayar',
    icon: Icons.payments_rounded,
  ),
  diterima(
    stepIndex: 0,
    title: 'Pesanan Diterima',
    subtitle: 'Pesanan sudah dikonfirmasi & masuk antrean barista',
    badgeText: 'Dikonfirmasi',
    icon: Icons.receipt_long_rounded,
  ),
  diproses(
    stepIndex: 1,
    title: 'Sedang Disiapkan',
    subtitle: 'Barista sedang meracik minuman & hidanganmu di bar',
    badgeText: 'Sedang Dibuat',
    icon: Icons.coffee_maker_rounded,
  ),
  siapDiambil(
    stepIndex: 2,
    title: 'Siap Diambil',
    subtitle: 'Pesananmu sudah selesai! Silakan ambil di Counter Pick-up',
    badgeText: 'Siap di Counter',
    icon: Icons.notifications_active_rounded,
  ),
  selesai(
    stepIndex: 3,
    title: 'Pesanan Selesai',
    subtitle: 'Pesanan telah diambil. Terima kasih & selamat menikmati!',
    badgeText: 'Selesai',
    icon: Icons.check_circle_rounded,
  ),
  dibatalkan(
    stepIndex: -2,
    title: 'Pesanan Dibatalkan',
    subtitle: 'Pesanan ini dibatalkan oleh kasir & poin/dana telah disesuaikan',
    badgeText: 'Dibatalkan',
    icon: Icons.cancel_rounded,
  );

  final int stepIndex;
  final String title;
  final String subtitle;
  final String badgeText;
  final IconData icon;

  const OrderStatus({
    required this.stepIndex,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.icon,
  });

  bool get isTerminal =>
      this == OrderStatus.selesai || this == OrderStatus.dibatalkan;

  bool isPassed(OrderStatus current) =>
      current != OrderStatus.dibatalkan && current.stepIndex > stepIndex;
  bool isCurrent(OrderStatus current) => current.stepIndex == stepIndex;
}

/// Model data untuk pesanan BreakFree dengan dukungan Live Tracking.
class OrderModel {
  final String id;
  final String queueNumber;
  final String counterName;
  final String orderType;
  final String pickupType;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final OrderStatus status;
  final List<CartItemModel> items;
  final int subtotal;
  final int discountAmount;
  final String? voucherCode;
  final int voucherDiscount;
  final int pointsUsed;
  final int pointsDiscount;
  final int pointsEarned;
  final int taxAmount;
  final int totalPrice;
  final String paymentMethod;
  final String? paymentStatus;
  final String? paymentChannel;
  final String? midtransOrderId;
  final String? snapToken;
  final String? snapRedirectUrl;
  final String? promoCode;
  final int estimatedMinutes;
  final String? cashierName;
  final String? cancelReason;
  final String baristaName;
  final String baristaNote;
  final Map<OrderStatus, DateTime> statusTimes;
  final Map<String, dynamic>? points;

  const OrderModel({
    required this.id,
    required this.queueNumber,
    this.counterName = 'Counter Bar 01',
    this.orderType = 'DINE_IN',
    this.pickupType = 'Dine-in (Minum di Kafe)',
    required this.createdAt,
    this.updatedAt,
    required this.status,
    required this.items,
    this.subtotal = 0,
    this.discountAmount = 0,
    this.voucherCode,
    this.voucherDiscount = 0,
    this.pointsUsed = 0,
    this.pointsDiscount = 0,
    this.pointsEarned = 0,
    this.taxAmount = 0,
    required this.totalPrice,
    required this.paymentMethod,
    this.paymentStatus,
    this.paymentChannel,
    this.midtransOrderId,
    this.snapToken,
    this.snapRedirectUrl,
    this.promoCode,
    this.estimatedMinutes = 8,
    this.cashierName,
    this.cancelReason,
    this.baristaName = 'Tim Barista BreakFree',
    this.baristaNote = 'Pesanan sedang diproses oleh tim BreakFree.',
    this.statusTimes = const {},
    this.points,
  });

  bool get isCancelled => status == OrderStatus.dibatalkan;

  bool get hasPendingMidtrans =>
      status == OrderStatus.menungguPembayaran &&
      snapRedirectUrl != null &&
      snapRedirectUrl!.trim().isNotEmpty;

  String get formattedTotalPrice => AppFormatters.formatRupiah(totalPrice);

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  int get computedSubtotal => subtotal > 0
      ? subtotal
      : items.fold<int>(0, (sum, item) => sum + (item.price * item.quantity));

  int get effectiveVoucherDiscount =>
      voucherDiscount > 0 ? voucherDiscount : discountAmount;

  String get cashierDisplayName {
    if (cashierName != null && cashierName!.trim().isNotEmpty) {
      return cashierName!.trim();
    }
    if (baristaName.trim().isNotEmpty &&
        baristaName.trim() != 'Barista Reza') {
      return baristaName.trim();
    }
    return 'Tim Barista BreakFree';
  }

  String get displayOrderType {
    final upper = orderType.trim().toUpperCase();
    if (upper == 'TAKEAWAY' ||
        pickupType.toLowerCase().contains('takeaway') ||
        pickupType.toLowerCase().contains('take away') ||
        pickupType.toLowerCase().contains('bungkus')) {
      return 'Takeaway (Bungkus Bawa Pulang)';
    }
    return 'Dine-in (Self Pick-Up)';
  }

  OrderModel copyWith({
    String? id,
    String? queueNumber,
    String? counterName,
    String? orderType,
    String? pickupType,
    DateTime? createdAt,
    DateTime? updatedAt,
    OrderStatus? status,
    List<CartItemModel>? items,
    int? subtotal,
    int? discountAmount,
    String? voucherCode,
    int? voucherDiscount,
    int? pointsUsed,
    int? pointsDiscount,
    int? pointsEarned,
    int? taxAmount,
    int? totalPrice,
    String? paymentMethod,
    String? paymentStatus,
    String? paymentChannel,
    String? midtransOrderId,
    String? snapToken,
    String? snapRedirectUrl,
    String? promoCode,
    int? estimatedMinutes,
    String? cashierName,
    String? cancelReason,
    String? baristaName,
    String? baristaNote,
    Map<OrderStatus, DateTime>? statusTimes,
    Map<String, dynamic>? points,
  }) {
    return OrderModel(
      id: id ?? this.id,
      queueNumber: queueNumber ?? this.queueNumber,
      counterName: counterName ?? this.counterName,
      orderType: orderType ?? this.orderType,
      pickupType: pickupType ?? this.pickupType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      voucherCode: voucherCode ?? this.voucherCode,
      voucherDiscount: voucherDiscount ?? this.voucherDiscount,
      pointsUsed: pointsUsed ?? this.pointsUsed,
      pointsDiscount: pointsDiscount ?? this.pointsDiscount,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      taxAmount: taxAmount ?? this.taxAmount,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentChannel: paymentChannel ?? this.paymentChannel,
      midtransOrderId: midtransOrderId ?? this.midtransOrderId,
      snapToken: snapToken ?? this.snapToken,
      snapRedirectUrl: snapRedirectUrl ?? this.snapRedirectUrl,
      promoCode: promoCode ?? this.promoCode,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      cashierName: cashierName ?? this.cashierName,
      cancelReason: cancelReason ?? this.cancelReason,
      baristaName: baristaName ?? this.baristaName,
      baristaNote: baristaNote ?? this.baristaNote,
      statusTimes: statusTimes ?? this.statusTimes,
      points: points ?? this.points,
    );
  }
}
