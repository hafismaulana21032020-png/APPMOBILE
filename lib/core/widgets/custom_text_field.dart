import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? label;
  final IconData prefixIcon;
  final bool isObscure;
  final Widget? suffixIcon;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.label,
    this.isObscure = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final textField = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.inputBorderColor, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: AppColors.darkText),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.inputHint,
          prefixIcon: Icon(prefixIcon, color: AppColors.iconColor, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );

    if (label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label!, style: AppTextStyles.inputLabel),
          const SizedBox(height: 6),
          textField,
        ],
      );
    }

    return textField;
  }
}
