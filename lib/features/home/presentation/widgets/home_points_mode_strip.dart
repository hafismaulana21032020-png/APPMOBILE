import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../account/domain/services/user_service.dart';
import '../../domain/services/pickup_mode_service.dart';
import 'pickup_mode_sheet.dart';

class HomePointsModeStrip extends StatelessWidget {
  const HomePointsModeStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Kolom Kiri: Cashback & Poin
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.cashbackPoints);
                  },
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: AnimatedBuilder(
                      animation: UserService.instance,
                      builder: (context, _) {
                        final points = UserService.instance.points;
                        final potentialSaving = (points ~/ 100) * 1000;

                        return Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFFE082),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.stars_rounded,
                                color: Color(0xFFE6A100),
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${AppFormatters.formatThousands(points)} Poin',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    potentialSaving > 0
                                        ? 'Hemat s/d ${AppFormatters.formatRupiah(potentialSaving)}'
                                        : 'Tukar & hemat pesanan',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Garis Pemisah Vertikal Tipis
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: AppColors.borderLight,
            ),

            // Kolom Kanan: Mode Pengambilan Self-Service (Dine-in / Takeaway di Counter Bar)
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => showPickupModeSheet(context),
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: AnimatedBuilder(
                      animation: PickupModeService.instance,
                      builder: (context, _) {
                        final pickupService = PickupModeService.instance;

                        return Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.accentLightBrown
                                    .withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryBrown
                                      .withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                pickupService.isDineIn
                                    ? Icons.local_cafe_outlined
                                    : Icons.shopping_bag_outlined,
                                color: AppColors.primaryBrown,
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    pickupService.displayTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    pickupService.subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
