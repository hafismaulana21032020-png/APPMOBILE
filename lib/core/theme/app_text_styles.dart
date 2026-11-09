import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Brand Header
  static const TextStyle brandTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.darkBrown,
    letterSpacing: -0.3,
  );

  static const TextStyle brandSubtitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
  );

  // Headings
  static const TextStyle headingLarge = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.bold,
    color: AppColors.darkText,
    letterSpacing: -0.4,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.darkText,
  );

  // Subtitles & Body
  static const TextStyle bodyDescription = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
    height: 1.35,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.darkText,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.secondaryText,
  );

  // Form
  static const TextStyle inputLabel = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.bold,
    color: AppColors.darkBrown,
  );

  static const TextStyle inputHint = TextStyle(
    color: AppColors.hintColor,
    fontSize: 13.5,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    color: AppColors.darkText,
  );

  static const TextStyle helperText = TextStyle(
    fontSize: 11,
    color: AppColors.secondaryText,
  );

  // Buttons & Links
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  static const TextStyle linkText = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: AppColors.darkBrown,
  );

  static const TextStyle linkTextBold = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.bold,
    color: AppColors.darkBrown,
  );

  // Security footer note
  static const TextStyle securityNote = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
  );
}
