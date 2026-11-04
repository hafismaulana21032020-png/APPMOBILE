import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';

class ResetPasswordSuccessDialog extends StatelessWidget {
  final VoidCallback onLoginPressed;

  const ResetPasswordSuccessDialog({
    super.key,
    required this.onLoginPressed,
  });

  static Future<void> show(BuildContext context, {required VoidCallback onLoginPressed}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResetPasswordSuccessDialog(onLoginPressed: onLoginPressed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: const BoxDecoration(
              color: AppColors.cardBgColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.primaryBrown,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Kata Sandi Diperbarui!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kata sandi kamu berhasil diubah. Silakan masuk kembali dengan kata sandi baru.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeightSm,
            child: ElevatedButton(
              onPressed: onLoginPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrown,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              child: const Text(
                'Masuk Sekarang',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

