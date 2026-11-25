import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../order/domain/models/order_model.dart';
import '../../../order/domain/services/order_service.dart';

class MidtransPaymentSheet extends StatefulWidget {
  final OrderModel order;
  final void Function(Map<String, dynamic> statusResult)? onPaid;
  final void Function(String message)? onFailed;
  final VoidCallback? onPayLater;

  const MidtransPaymentSheet({
    super.key,
    required this.order,
    this.onPaid,
    this.onFailed,
    this.onPayLater,
  });

  static Future<void> show(
    BuildContext context, {
    required OrderModel order,
    void Function(Map<String, dynamic> statusResult)? onPaid,
    void Function(String message)? onFailed,
    VoidCallback? onPayLater,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => MidtransPaymentSheet(
        order: order,
        onPaid: onPaid,
        onFailed: onFailed,
        onPayLater: onPayLater,
      ),
    );
  }

  @override
  State<MidtransPaymentSheet> createState() => _MidtransPaymentSheetState();
}

class _MidtransPaymentSheetState extends State<MidtransPaymentSheet> {
  Timer? _pollingTimer;
  bool _isChecking = false;
  bool _hasCompleted = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _verifyStatus(silent: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _openMidtransPage() async {
    final rawUrl = widget.order.snapRedirectUrl;
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link pembayaran Midtrans tidak tersedia.'),
          backgroundColor: Color(0xFFC93B2B),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null) return;

    var launched = false;
    try {
      launched = await launchUrl(
        uri,
        mode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } catch (_) {
      launched = false;
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka halaman Midtrans di browser.'),
          backgroundColor: Color(0xFFC93B2B),
        ),
      );
    }
  }

  Future<void> _verifyStatus({bool silent = false}) async {
    if (_isChecking || _hasCompleted) return;
    if (mounted && !silent) {
      setState(() {
        _isChecking = true;
        _statusMessage = 'Memeriksa status pembayaran ke Midtrans...';
      });
    } else {
      _isChecking = true;
    }

    try {
      final res = await OrderService.instance.checkMidtransStatus(widget.order.id);
      if (!mounted || _hasCompleted) return;

      if (res['isPaid'] == true) {
        _hasCompleted = true;
        _pollingTimer?.cancel();
        Navigator.pop(context);
        widget.onPaid?.call(res);
        return;
      }

      if (res['isFailed'] == true) {
        _hasCompleted = true;
        _pollingTimer?.cancel();
        Navigator.pop(context);
        widget.onFailed?.call(
          res['message']?.toString() ?? 'Pembayaran Midtrans dibatalkan atau kedaluwarsa.',
        );
        return;
      }

      if (!silent) {
        setState(() {
          _statusMessage =
              res['message']?.toString() ??
              'Pembayaran masih berstatus pending di Midtrans.';
        });
      }
    } finally {
      _isChecking = false;
      if (mounted && !silent) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF90CAF9)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, size: 13, color: Color(0xFF1565C0)),
                    SizedBox(width: 5),
                    Text(
                      'MIDTRANS PAYMENT GATEWAY (SANDBOX)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1565C0),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Selesaikan Pembayaran',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pesanan ${order.id} • Antrean ${order.queueNumber}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F6F0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.inputBorderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Tagihan',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        Text(
                          order.formattedTotalPrice,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBrown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: AppColors.inputBorderColor),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Icon(Icons.payments_outlined, size: 16, color: AppColors.primaryBrown),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Mendukung QRIS, GoPay, ShopeePay, Transfer Bank / Virtual Account (BCA, BRI, BNI, Mandiri)',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.darkText,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFE65100),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _statusMessage ??
                            'Status otomatis dicek setiap 3 detik setelah Anda membayar di halaman Midtrans.',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF795548),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _openMidtransPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 18),
                  label: const Text(
                    'Buka Halaman Bayar Midtrans',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: _isChecking ? null : () => _verifyStatus(silent: false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBrown),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: Icon(
                    Icons.sync_rounded,
                    size: 18,
                    color: _isChecking ? Colors.grey : AppColors.primaryBrown,
                  ),
                  label: Text(
                    _isChecking ? 'Memeriksa Status...' : 'Saya Sudah Bayar • Cek Status',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: _isChecking ? Colors.grey : AppColors.primaryBrown,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              TextButton(
                onPressed: () {
                  _pollingTimer?.cancel();
                  Navigator.pop(context);
                  widget.onPayLater?.call();
                },
                child: const Text(
                  'Bayar Nanti / Lihat Live Tracking',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
