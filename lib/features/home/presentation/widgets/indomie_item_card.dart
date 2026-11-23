import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../domain/models/product_model.dart';

class IndomieLevelOption {
  final String level;
  final int price;

  const IndomieLevelOption({required this.level, required this.price});

  String get formattedPrice => AppFormatters.formatRupiah(price);
}

class IndomieItemCard extends StatefulWidget {
  final ProductModel product;
  final List<IndomieLevelOption> levelOptions;
  final void Function(ProductModel product, IndomieLevelOption selectedLevel) onAddToCart;

  const IndomieItemCard({
    super.key,
    required this.product,
    required this.levelOptions,
    required this.onAddToCart,
  });

  @override
  State<IndomieItemCard> createState() => _IndomieItemCardState();
}

class _IndomieItemCardState extends State<IndomieItemCard> {
  int _selectedLevelIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isAvailable = widget.product.isAvailable;
    final safeIndex = widget.levelOptions.isEmpty
        ? 0
        : _selectedLevelIndex.clamp(0, widget.levelOptions.length - 1);
    final selectedOption =
        widget.levelOptions.isNotEmpty ? widget.levelOptions[safeIndex] : null;

    return Opacity(
      opacity: isAvailable ? 1.0 : 0.65,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isAvailable ? Colors.white : const Color(0xFFECEAE5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAvailable ? AppColors.inputBorderColor : const Color(0xFFD6D1C7),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Image & Info (Klik untuk buka opsi & kuantitas)
            GestureDetector(
              onTap: () {
                if (!isAvailable) return;
                if (selectedOption != null) {
                  widget.onAddToCart(widget.product, selectedOption);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ColorFiltered(
                            colorFilter: isAvailable
                                ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                                : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                            child: Image.asset(
                              widget.product.image.isNotEmpty
                                  ? widget.product.image
                                  : AppAssets.nasiGorengTelur,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppColors.cardBgColor,
                                child: const Center(
                                  child: Icon(Icons.restaurant_rounded,
                                      size: 28, color: AppColors.primaryBrown),
                                ),
                              ),
                            ),
                          ),
                          if (!isAvailable)
                            Container(
                              color: Colors.black.withValues(alpha: 0.45),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC93B2B),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'SOLD OUT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryText,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Level selection header
          const Text(
            'Pilih level',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 6),

          // Level options pills
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: List.generate(widget.levelOptions.length, (index) {
              final option = widget.levelOptions[index];
              final isSelected = index == _selectedLevelIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLevelIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBrown : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppColors.inputBorderColor,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    '${option.level} • ${option.formattedPrice}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.darkBrown,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Bottom Row: Mulai Price & + Add
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Mulai ${widget.product.formattedPrice}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? AppColors.darkText : const Color(0xFF8C827A),
                      ),
                    ),
                    if (!isAvailable) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFFFCDD2)),
                        ),
                        child: const Text(
                          'Habis',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC62828),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (!isAvailable) return;
                    if (selectedOption != null) {
                      widget.onAddToCart(widget.product, selectedOption);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable ? AppColors.primaryBrown : const Color(0xFFDDD8CE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isAvailable ? '+ Add' : 'Sold Out',
                      style: TextStyle(
                        color: isAvailable ? Colors.white : const Color(0xFF7A726A),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  }
}

