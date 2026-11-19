import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/routes/app_routes.dart';

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

                    // ── Double Check Icon ──
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF4CAF50),
                          width: 2.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.done_all_rounded,
                        color: Color(0xFF4CAF50),
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Title ──
                    const Text(
                      'Pembayaran Berhasil!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Subtitle ──
                    const Text(
                      'Pesananmu sudah diteruskan ke barista dapur\nBreakFree.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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

                          // Row: Estimasi Tunggu
                          const _InfoRow(
                            label: 'Estimasi Tunggu',
                            value: '8 – 12 Menit',
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
                            value: '$paymentMethod (GoPay)',
                            valueBold: true,
                            valueColor: AppColors.darkText,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

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

