import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AccountStatsRow extends StatelessWidget {
  final int poin;
  final int pesanan;
  final int promo;

  const AccountStatsRow({
    super.key,
    required this.poin,
    required this.pesanan,
    required this.promo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorderColor, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatItem(
              label: 'Poin',
              value: poin >= 1000
                  ? '${(poin / 1000).toStringAsFixed(0)}.${(poin % 1000).toString().padLeft(3, '0')}'
                  : poin.toString(),
            ),
            const VerticalDivider(
              color: AppColors.inputBorderColor,
              thickness: 1,
              width: 1,
            ),
            _StatItem(label: 'Pesanan', value: pesanan.toString()),
            const VerticalDivider(
              color: AppColors.inputBorderColor,
              thickness: 1,
              width: 1,
            ),
            _StatItem(label: 'Promo', value: promo.toString()),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

