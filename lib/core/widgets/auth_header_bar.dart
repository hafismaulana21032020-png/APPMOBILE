import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AuthHeaderBar extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const AuthHeaderBar({
    super.key,
    this.onBackPressed,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBackButton) ...[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.inputBorderColor, width: 1),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20, color: AppColors.darkText),
              padding: EdgeInsets.zero,
              onPressed: onBackPressed ?? () => Navigator.maybePop(context),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'BreakFree',
              style: AppTextStyles.brandTitle,
            ),
            Text(
              'Malang, Indonesia',
              style: AppTextStyles.brandSubtitle,
            ),
          ],
        ),
      ],
    );
  }
}

