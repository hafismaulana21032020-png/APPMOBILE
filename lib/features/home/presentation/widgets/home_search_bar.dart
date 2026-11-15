import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const HomeSearchBar({
    super.key,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.inputBorderColor, width: 1.0),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.inputText,
        decoration: InputDecoration(
          hintText: 'Cari kopi favoritmu...',
          hintStyle: AppTextStyles.inputHint,
          prefixIcon: const Icon(Icons.search, color: AppColors.iconColor, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
