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

  bool isPassed(OrderStatus current) => current.stepIndex > stepIndex;
  bool isCurrent(OrderStatus current) => current.stepIndex == stepIndex;
}

/// Model data untuk pesanan BreakFree dengan dukungan Live Tracking.
class OrderModel {
  final String id;
  final String queueNumber;
  final String counterName;
  final String pickupType;
  final DateTime createdAt;
  final OrderStatus status;
  final List<CartItemModel> items;
  final int totalPrice;
  final String paymentMethod;
  final String? promoCode;
  final int estimatedMinutes;
  final String baristaName;
  final String baristaNote;
  final Map<OrderStatus, DateTime> statusTimes;

  const OrderModel({
    required this.id,
    required this.queueNumber,
    this.counterName = 'Counter Bar 01',
    this.pickupType = 'Dine-in (Minum di Kafe)',
    required this.createdAt,
    required this.status,
    required this.items,
    required this.totalPrice,
    required this.paymentMethod,
    this.promoCode,
    this.estimatedMinutes = 8,
    this.baristaName = 'Barista Reza',
    this.baristaNote =
        'Biji kopi Sarijan baru diekstrak, sedang menuang susu segar creamy.',
    this.statusTimes = const {},
  });

  String get formattedTotalPrice => AppFormatters.formatRupiah(totalPrice);

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  OrderModel copyWith({
    String? id,
    String? queueNumber,
    String? counterName,
    String? pickupType,
    DateTime? createdAt,
    OrderStatus? status,
    List<CartItemModel>? items,
    int? totalPrice,
    String? paymentMethod,
    String? promoCode,
    int? estimatedMinutes,
    String? baristaName,
    String? baristaNote,
    Map<OrderStatus, DateTime>? statusTimes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      queueNumber: queueNumber ?? this.queueNumber,
      counterName: counterName ?? this.counterName,
      pickupType: pickupType ?? this.pickupType,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      promoCode: promoCode ?? this.promoCode,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      baristaName: baristaName ?? this.baristaName,
      baristaNote: baristaNote ?? this.baristaNote,
      statusTimes: statusTimes ?? this.statusTimes,
    );
  }
}
