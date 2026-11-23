import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeBundleCard extends StatelessWidget {
  final VoidCallback onTap;
  final double? width;

  const HomeBundleCard({
    super.key,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: width ?? double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inputBorderColor, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'LEBIH SERU BERDUA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '2 Ice Kopi Susu • Rp28.000',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Hemat Rp4.000 dari harga satuan',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.primaryBrown,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

