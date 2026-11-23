import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/home_tab_controller.dart';

class _CategoryChipItem {
  final String label;
  final String targetCategory;
  final IconData icon;

  const _CategoryChipItem({
    required this.label,
    required this.targetCategory,
    required this.icon,
  });
}

class HomeCategoryChips extends StatelessWidget {
  const HomeCategoryChips({super.key});

  static const List<_CategoryChipItem> _items = [
    _CategoryChipItem(
      label: 'Terlaris',
      targetCategory: 'Semua',
      icon: Icons.local_fire_department_rounded,
    ),
    _CategoryChipItem(
      label: 'Kopi',
      targetCategory: 'Kopi',
      icon: Icons.coffee_rounded,
    ),
    _CategoryChipItem(
      label: 'Non-Kopi',
      targetCategory: 'Non-Kopi',
      icon: Icons.local_drink_rounded,
    ),
    _CategoryChipItem(
      label: 'Makanan',
      targetCategory: 'Makanan',
      icon: Icons.restaurant_rounded,
    ),
    _CategoryChipItem(
      label: 'Camilan',
      targetCategory: 'Snack',
      icon: Icons.cookie_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = _items[index];

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HomeTabController.instance.selectTab(
                  1,
                  category: item.targetCategory,
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.borderLight,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.025),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 16,
                      color: item.label == 'Terlaris'
                          ? const Color(0xFFE65100)
                          : AppColors.primaryBrown,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
