import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../account/domain/services/user_service.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil argumen dari route
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final paymentMethod = args?['paymentMethod'] as String? ?? 'QRIS';
    final orderNumber = args?['orderNumber'] as String? ??
        '#BF-${(Random().nextInt(9000) + 1000).toString().padLeft(4, '0')}';
    final queueNumber = args?['queueNumber'] as String? ?? 'A-01';
    final isCash = paymentMethod.toLowerCase().contains('cash') ||
        paymentMethod.toLowerCase().contains('tunai');
    final totalPayment = args?['totalPayment'] as int? ?? 0;

    // Data Poin & Cashback
    final points = args?['points'] as Map<String, dynamic>?;
    final earned = points != null
        ? (points['earned'] as int? ?? 0)
        : (args?['earnedPoints'] as int? ?? 0);
    final used = points != null ? (points['used'] as int? ?? 0) : 0;
    final discountAmount = points != null ? (points['discountAmount'] as int? ?? 0) : 0;
    final currentBalance = points != null && points['currentBalance'] != null
        ? (points['currentBalance'] as int)
        : UserService.instance.points;
    final isPending = points != null ? (points['isPending'] as bool? ?? isCash) : isCash;

    // Sinkronkan saldo terkini jika ada
    if (points != null && points['currentBalance'] != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UserService.instance.setPoints(currentBalance);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ================= SCROLLABLE CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // ── Status Icon ──
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isCash
                            ? const Color(0xFFFFF8E1)
                            : const Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCash
                              ? const Color(0xFFFFB300)
                              : const Color(0xFF4CAF50),
                          width: 2.5,
                        ),
                      ),
                      child: Icon(
                        isCash
                            ? Icons.payments_rounded
                            : Icons.done_all_rounded,
                        color: isCash
                            ? const Color(0xFFE65100)
                            : const Color(0xFF4CAF50),
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Title ──
                    Text(
                      isCash ? 'Pesanan Terbuat!' : 'Pembayaran Berhasil!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Subtitle ──
                    Text(
                      isCash
                          ? 'Silakan tunjukkan nomor antrean dan lakukan pembayaran tunai di kasir agar pesanan segera diracik.'
                          : 'Pesananmu sudah diteruskan ke barista dapur\nBreakFree.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Info Card ──
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.inputBorderColor,
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Row: Nomor Antrean
                          _InfoRow(
                            label: 'Nomor Antrean',
                            value: queueNumber,
                            valueBold: true,
                            valueColor: AppColors.darkBrown,
                          ),

                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.inputBorderColor,
                          ),

                          // Row: Nomor Pesanan
                          _InfoRow(
                            label: 'Nomor Pesanan',
                            value: orderNumber,
                            valueBold: true,
                            valueColor: AppColors.darkText,
                          ),

                          // Divider
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.inputBorderColor,
                          ),

                          // Row: Metode Bayar
                          _InfoRow(
                            label: 'Metode Bayar',
                            value: isCash
                                ? 'Cash (Tunai di Kasir)'
                                : 'QRIS Resmi (Break Free)',
                            valueBold: true,
                            valueColor: AppColors.darkText,
                          ),

                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.inputBorderColor,
                          ),

                          // Row: Status Pesanan
                          _InfoRow(
                            label: 'Status',
                            value: isCash
                                ? 'Menunggu Pembayaran'
                                : 'Diterima Dapur',
                            valueBold: true,
                            valueColor: isCash
                                ? const Color(0xFFE65100)
                                : const Color(0xFF2E7D32),
                          ),

                          if (totalPayment > 0) ...[
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.inputBorderColor,
                            ),

                            // Row: Total Pembayaran (termasuk PPN 10%)
                            _InfoRow(
                              label: 'Total Bayar (Inc. PPN)',
                              value: AppFormatters.formatRupiah(totalPayment),
                              valueBold: true,
                              valueColor: AppColors.darkBrown,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Golden Reward Card (Poin Cashback & Hemat) ──
                    if (earned > 0 || used > 0) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF9C4), Color(0xFFFFF176)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFFFD54F),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD54F).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.stars_rounded,
                                    color: Color(0xFFF57F17),
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isPending
                                            ? 'Estimasi +$earned Poin Cashback'
                                            : '+$earned Poin BreakFree Masuk!',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF5D4037),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isPending
                                            ? 'Poin otomatis masuk setelah pembayaran dikonfirmasi kasir'
                                            : 'Total saldo poinmu sekarang: $currentBalance poin',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF795548),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (used > 0) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 16,
                                      color: Color(0xFF2E7D32),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Hemat ${AppFormatters.formatRupiah(discountAmount)} ($used poin terpakai)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // ── Motivational Banner ──
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.cardBgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          // Coffee image on left
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(14),
                              bottomLeft: Radius.circular(14),
                            ),
                            child: Image.asset(
                              AppAssets.coffeeBanner,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // Text on right
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              child: Text(
                                'Santai dulu! Sambil nunggu kopi siap, kamu bisa buka modul kuliahmu atau obrolin tugas kelompok bareng.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.darkBrown,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================= BOTTOM BUTTONS =================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lacak Pesanan button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.orderTracking);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Lacak Pesanan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Kembali ke Menu Utama link
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Kembali ke Menu Utama',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBrown,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primaryBrown,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget baris info (label di kiri, value di kanan)
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool valueBold;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.secondaryText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}

