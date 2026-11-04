import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Brand Header
  static const TextStyle brandTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryBrown,
  );

  static const TextStyle brandSubtitle = TextStyle(
    fontSize: 12,
    color: AppColors.secondaryText,
  );

  // Headings
  static const TextStyle headingLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.darkText,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.darkText,
  );

  // Subtitles & Body
  static const TextStyle bodyDescription = TextStyle(
    fontSize: 13,
    color: AppColors.secondaryText,
    height: 1.4,
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
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
  );

  static const TextStyle inputHint = TextStyle(
    color: AppColors.hintColor,
    fontSize: 13,
  );

  static const TextStyle helperText = TextStyle(
    fontSize: 11,
    color: AppColors.secondaryText,
  );

  // Buttons & Links
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle linkText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBrown,
  );

  static const TextStyle linkTextBold = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryBrown,
  );
}

