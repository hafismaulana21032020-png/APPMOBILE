import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/services/pickup_mode_service.dart';

/// Membuka bottom sheet pilihan mode pengambilan self-service di counter bar.
void showPickupModeSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => const _PickupModeSheetContent(),
  );
}

class _PickupModeSheetContent extends StatefulWidget {
  const _PickupModeSheetContent();

  @override
  State<_PickupModeSheetContent> createState() =>
      _PickupModeSheetContentState();
}

class _PickupModeSheetContentState extends State<_PickupModeSheetContent> {
  late PickupMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = PickupModeService.instance.mode;
  }

  void _saveSelection() {
    PickupModeService.instance.setMode(_selectedMode);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedMode == PickupMode.dineIn
              ? 'Mode aktif: Self Pick-Up • Dine-in (Nikmati di Kedai)'
              : 'Mode aktif: Self Pick-Up • Takeaway (Bawa Pulang)',
        ),
        backgroundColor: AppColors.primaryBrown,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildOptionCard({
    required PickupMode mode,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedMode == mode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMode = mode;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFFDF9) : AppColors.cardBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryBrown
                  : AppColors.borderLight,
              width: isSelected ? 1.8 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryBrown.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBrown
                      : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : AppColors.darkBrown,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.darkBrown
                            : AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected
                    ? AppColors.primaryBrown
                    : AppColors.hintColor,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mode Pengambilan Pesanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'BreakFree berkonsep mandiri (self-service). Ambil hidanganmu langsung di counter bar.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.secondaryText,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            // Opsi 1: Dine-in
            _buildOptionCard(
              mode: PickupMode.dineIn,
              title: 'Dine-in (Self-Service)',
              description:
                  'Nikmati di kedai, ambil sendiri di bar saat antrean dipanggil.',
              icon: Icons.local_cafe_outlined,
            ),
            const SizedBox(height: 10),

            // Opsi 2: Takeaway
            _buildOptionCard(
              mode: PickupMode.takeaway,
              title: 'Takeaway (Bawa Pulang)',
              description:
                  'Dikemas untuk dibawa pulang, ambil langsung di counter bar.',
              icon: Icons.shopping_bag_outlined,
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _saveSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrown,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: const Text(
                  'Terapkan Mode Pengambilan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
