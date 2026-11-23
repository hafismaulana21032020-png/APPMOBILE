import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../domain/services/promo_service.dart';

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
    return AnimatedBuilder(
      animation: PromoService.instance,
      builder: (context, _) {
        final activePromo = PromoService.instance.primaryPromo;

        final code = activePromo?.code ?? 'BREAK20';
        final title = activePromo?.title ?? 'Diskon 20% buat jedamu';
        final minPurchase = activePromo?.minPurchase ?? 30000;
        final maxDiscount = activePromo?.maxDiscount ?? 10000;
        final type = activePromo?.type ?? 'PERCENTAGE';
        final value = activePromo?.value ?? 20;

        final termsText =
            'Min. ${AppFormatters.formatRupiah(minPurchase)}${maxDiscount > 0 ? ' • Maks. ${AppFormatters.formatRupiah(maxDiscount)}' : ''}';

        final discountBadgeText = type == 'PERCENTAGE'
            ? '$value%'
            : 'Rp ${value >= 1000 ? '${value ~/ 1000}rb' : value}';

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
                    children: [
                      const Text(
                        'VOUCHER SPESIAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        termsText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Kode: $code',
                        style: const TextStyle(
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
                    Text(
                      discountBadgeText,
                      style: const TextStyle(
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
      },
    );
  }
}
