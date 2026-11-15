import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int orderBadgeCount;

  const HomeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.orderBadgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.inputBorderColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.article_outlined,
                activeIcon: Icons.article_rounded,
                label: 'Menu',
              ),
              _buildAiAssistantNavItem(
                index: 2,
                label: 'Asisten AI',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_outline,
                activeIcon: Icons.person_rounded,
                label: 'Akun',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiAssistantNavItem({
    required int index,
    required String label,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBrown,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.darkBrown
                        : AppColors.secondaryText,
                  ),
                  child: Text(label, maxLines: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.darkBrown : AppColors.secondaryText;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey<bool>(isSelected),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: color,
                  ),
                  child: Text(label, maxLines: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
