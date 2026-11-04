import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'BreakFree',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBrown,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Malang, Indonesia',
          style: AppTextStyles.brandSubtitle,
        ),
      ],
    );
  }
}

