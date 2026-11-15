import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';

class CoffeeBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final double? height;

  const CoffeeBanner({
    super.key,
    this.title = 'Jeda sejenak, kopi dulu.',
    this.subtitle = 'Kopi favoritmu, selalu dekat denganmu.',
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final minHeight = height ?? AppDimensions.bannerHeight;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AppAssets.coffeeBanner,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.primaryBrown,
                  child: const Center(
                    child: Icon(Icons.coffee, size: 50, color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.2,
                      ),
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
