import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class AccountBannerCard extends StatelessWidget {
  final String userName;

  const AccountBannerCard({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkBrown,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AppAssets.coffeeBanner,
                fit: BoxFit.cover,
                color: const Color(0xAA2A1A0F),
                colorBlendMode: BlendMode.multiply,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: AppColors.darkBrown),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 130),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge AKUN AKTIF
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.promoBadgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'AKUN AKTIF',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3000),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Welcome Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat datang kembali',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withAlpha(204),
                          ),
                        ),
                        Text(
                          userName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Kelola profil, pesanan, dan preferensi akunku dengan lebih mudah',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withAlpha(179),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

