import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class HomeStoryCard extends StatelessWidget {
  final VoidCallback onExploreTap;

  const HomeStoryCard({
    super.key,
    required this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inputBorderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 155,
              child: Image.asset(
                AppAssets.aboutBreakfree,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  AppAssets.coffeeBanner,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.cardBgColor,
                    child: const Center(
                      child: Icon(
                        Icons.coffee_rounded,
                        size: 44,
                        color: AppColors.primaryBrown,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Apa itu BreakFree?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ruang jeda hangat di Malang untuk menikmati racikan kopi pilihan, menu rumahan, dan momen santai kapan saja.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onExploreTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrown,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Yuk, kenalan dengan BreakFree',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
    );
  }
}

