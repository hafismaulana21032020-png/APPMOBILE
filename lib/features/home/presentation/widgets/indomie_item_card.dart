import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/product_model.dart';

class IndomieLevelOption {
  final String level;
  final int price;

  const IndomieLevelOption({required this.level, required this.price});

  String get formattedPrice {
    final priceStr = price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return 'Rp $priceStr';
  }
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
    final selectedOption = widget.levelOptions.isNotEmpty
        ? widget.levelOptions[_selectedLevelIndex]
        : null;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorderColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Image & Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: SizedBox(
                  width: 72,
                  height: 72,
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
              Text(
                'Mulai ${widget.product.formattedPrice}',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
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
                      color: AppColors.primaryBrown,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '+ Add',
                      style: TextStyle(
                        color: Colors.white,
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
    );
  }
}

