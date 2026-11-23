import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'home_bundle_card.dart';
import 'home_voucher_card.dart';

class HomePromoPackagesSlider extends StatelessWidget {
  final bool isVoucherApplied;
  final VoidCallback onToggleVoucher;
  final VoidCallback onBundleTap;

  const HomePromoPackagesSlider({
    super.key,
    required this.isVoucherApplied,
    required this.onToggleVoucher,
    required this.onBundleTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Lebar kartu ~84% agar kartu berikutnya sedikit mengintip di tepi kanan
    final cardWidth = screenWidth * 0.84;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Promo & Paket Hemat',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: cardWidth,
                child: HomeVoucherCard(
                  width: cardWidth,
                  isApplied: isVoucherApplied,
                  onApplyTap: onToggleVoucher,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: cardWidth,
                child: HomeBundleCard(
                  width: cardWidth,
                  onTap: onBundleTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
