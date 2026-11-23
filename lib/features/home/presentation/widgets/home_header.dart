import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BreakFree',
                style: AppTextStyles.brandTitle,
              ),
              const SizedBox(height: 2),
              Row(
                children: const [
                  Text(
                    'Malang, Indonesia',
                    style: AppTextStyles.brandSubtitle,
                  ),
                  Text(
                    ' • Buka s/d 22.00',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Stack(
          children: [
            IconButton(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.notifications,
              ),
              icon: const Icon(
                Icons.notifications_none_rounded,
                size: 26,
                color: AppColors.darkBrown,
              ),
              tooltip: 'Notifikasi',
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
