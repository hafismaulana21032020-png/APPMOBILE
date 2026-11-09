import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AccountQuickActions extends StatelessWidget {
  final VoidCallback? onOrderTap;
  final VoidCallback? onCashbackTap;
  final VoidCallback? onFavoriteTap;

  const AccountQuickActions({
    super.key,
    this.onOrderTap,
    this.onCashbackTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickActionItem(
          icon: Icons.receipt_long_rounded,
          label: 'Pesanan\nSaya',
          onTap: onOrderTap ?? () {},
        ),
        const SizedBox(width: 10),
        _QuickActionItem(
          icon: Icons.savings_rounded,
          label: 'Cashback\npoin',
          onTap: onCashbackTap ?? () {},
        ),
        const SizedBox(width: 10),
        _QuickActionItem(
          icon: Icons.favorite_border_rounded,
          label: 'Favorit',
          onTap: onFavoriteTap ?? () {},
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.inputBorderColor, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cardBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.primaryBrown,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

