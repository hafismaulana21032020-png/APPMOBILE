import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeVoucherCard extends StatelessWidget {
  final bool isApplied;
  final VoidCallback onApplyTap;
  final double? width;

  const HomeVoucherCard({
    super.key,
    required this.isApplied,
    required this.onApplyTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isApplied
              ? AppColors.primaryBrown.withValues(alpha: 0.45)
              : const Color(0xFFEBE3D8),
          width: 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'VOUCHER SPESIAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Diskon 20% buat jedamu',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Min. Rp30.000 • Maks. Rp10.000',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Kode: BREAK20',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: const Color(0xFFE3D9CE),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '20%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: onApplyTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isApplied ? AppColors.darkBrown : AppColors.primaryBrown,
                    elevation: 0,
                    minimumSize: const Size(64, 32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    isApplied ? 'Dipakai' : 'Pakai',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

