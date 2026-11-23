import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeBundleCard extends StatelessWidget {
  final VoidCallback onTap;
  final double? width;
  final bool isAvailable;

  const HomeBundleCard({
    super.key,
    required this.onTap,
    this.width,
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.65,
          child: Ink(
            width: width ?? double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isAvailable ? Colors.white : const Color(0xFFECEAE5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isAvailable ? AppColors.inputBorderColor : const Color(0xFFD6D1C7),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'LEBIH SERU BERDUA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          if (!isAvailable) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFFFCDD2)),
                              ),
                              child: const Text(
                                'Sold Out',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFC62828),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '2 Ice Kopi Susu • Rp28.000',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? AppColors.darkText : const Color(0xFF8C827A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isAvailable
                            ? 'Hemat Rp4.000 dari harga satuan'
                            : 'Menu utama saat ini sedang habis',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isAvailable ? AppColors.secondaryText : const Color(0xFF8C827A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isAvailable ? Icons.add_circle_outline_rounded : Icons.close_rounded,
                  color: isAvailable ? AppColors.primaryBrown : const Color(0xFF8C827A),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

