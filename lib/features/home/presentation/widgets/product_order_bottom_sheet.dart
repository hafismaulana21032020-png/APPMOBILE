import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../cart/domain/services/cart_service.dart';
import '../../domain/models/product_model.dart';

/// Model untuk opsi varian produk (misal: Kukus/Goreng, Gula/Tanpa Gula, Level Pedas 1-3).
class ProductVariantOption {
  final String label;
  final int additionalPrice;
  final String? subtitle;

  const ProductVariantOption({
    required this.label,
    this.additionalPrice = 0,
    this.subtitle,
  });
}

/// Kelompok opsi untuk produk tertentu.
class ProductOptionGroup {
  final String title;
  final IconData icon;
  final List<ProductVariantOption> options;
  final int defaultIndex;

  const ProductOptionGroup({
    required this.title,
    required this.icon,
    required this.options,
    this.defaultIndex = 0,
  });
}

/// Modal bottom sheet interaktif untuk memilih varian/opsi, jumlah pcs, dan menambahkan catatan ke kasir.
class ProductOrderBottomSheet {
  ProductOrderBottomSheet._();
  
  /// Mendeteksi apakah produk memiliki opsi khusus seperti Gyoza, Kopi Sarijan, atau Indomie.
  static ProductOptionGroup? _getProductOptionGroup(ProductModel product) {
    final name = product.name.toLowerCase();

    // 1. GYOZA (Opsi Kukus dan Goreng)
    if (name.contains('gyoza')) {
      return const ProductOptionGroup(
        title: 'Pilihan Penyajian',
        icon: Icons.restaurant_menu_rounded,
        options: [
          ProductVariantOption(label: 'Goreng', subtitle: 'Renyah & gurih'),
          ProductVariantOption(label: 'Kukus', subtitle: 'Lembut & juicy'),
        ],
        defaultIndex: 0,
      );
    }

    // 2. KOPI HITAM SARIJAN (Opsi Gula dan Tanpa Gula)
    if (name.contains('kopi hitam')) {
      return const ProductOptionGroup(
        title: 'Pilihan Gula',
        icon: Icons.coffee_rounded,
        options: [
          ProductVariantOption(label: 'Tanpa Gula', additionalPrice: 0),
          ProductVariantOption(
            label: 'Gula',
            additionalPrice: 2000,
            subtitle: '+Rp 2.000',
          ),
        ],
        defaultIndex: 0,
      );
    }

    // 3. KOPI SUSU SARIJAN (Opsi Gula dan Tanpa Gula)
    if (name.contains('kopi susu')) {
      return const ProductOptionGroup(
        title: 'Pilihan Gula',
        icon: Icons.coffee_rounded,
        options: [
          ProductVariantOption(label: 'Tanpa Gula', additionalPrice: 0),
          ProductVariantOption(
            label: 'Gula',
            additionalPrice: 1000,
            subtitle: '+Rp 1.000',
          ),
        ],
        defaultIndex: 0,
      );
    }

    // 4. INDOMIE GORENG & INDOMIE NYEMEK (Opsi Kepedasan Level 1 s/d 3, kelipatan 1k)
    if (name.contains('indomie')) {
      return const ProductOptionGroup(
        title: 'Tingkat Kepedasan',
        icon: Icons.local_fire_department_rounded,
        options: [
          ProductVariantOption(label: 'Ori (Tidak Pedas)', additionalPrice: 0),
          ProductVariantOption(
            label: 'Level 1',
            additionalPrice: 1000,
            subtitle: '+Rp 1.000',
          ),
          ProductVariantOption(
            label: 'Level 2',
            additionalPrice: 2000,
            subtitle: '+Rp 2.000',
          ),
          ProductVariantOption(
            label: 'Level 3',
            additionalPrice: 3000,
            subtitle: '+Rp 3.000',
          ),
        ],
        defaultIndex: 0,
      );
    }

    return null;
  }

  /// Mendeteksi apakah produk merupakan kategori makanan atau snack yang memiliki opsi Take Away (+Rp 1.000).
  static bool _isFoodProduct(ProductModel product) {
    final cat = product.category.toLowerCase();
    final sub = (product.subcategory ?? '').toLowerCase();
    final n = product.name.toLowerCase();

    return cat.contains('makan') ||
        cat.contains('food') ||
        cat.contains('snack') ||
        sub.contains('makan') ||
        sub.contains('goreng') ||
        sub.contains('nyemek') ||
        sub.contains('paket') ||
        sub.contains('camilan') ||
        sub.contains('add-ons') ||
        n.contains('nasi') ||
        n.contains('mie') ||
        n.contains('indomie') ||
        n.contains('gyoza') ||
        n.contains('fries') ||
        n.contains('toast') ||
        n.contains('cireng') ||
        n.contains('tahu');
  }

  static void show(
    BuildContext context,
    ProductModel product, {
    String? initialOption,
  }) {
    if (!product.isAvailable) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maaf, ${product.name} saat ini sedang habis (sold out).'),
          backgroundColor: const Color(0xFFC93B2B),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    int quantity = 1;
    final noteController = TextEditingController();
    final optionGroup = _getProductOptionGroup(product);
    final isFood = _isFoodProduct(product);
    bool isTakeAway = initialOption != null &&
        (initialOption.toLowerCase().contains('take away') ||
            initialOption.toLowerCase().contains('takeaway') ||
            initialOption.toLowerCase().contains('bungkus'));

    int selectedOptionIndex = optionGroup?.defaultIndex ?? 0;
    if (optionGroup != null && initialOption != null) {
      final initialLower = initialOption.toLowerCase();
      final matchIdx = optionGroup.options.indexWhere(
        (opt) =>
            opt.label.toLowerCase() == initialLower ||
            opt.label.toLowerCase().contains(initialLower),
      );
      if (matchIdx != -1) {
        selectedOptionIndex = matchIdx;
      }
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final currentOption = optionGroup != null && optionGroup.options.isNotEmpty
                ? optionGroup.options[
                    selectedOptionIndex.clamp(0, optionGroup.options.length - 1)]
                : null;

            final packagingPrice = (isFood && isTakeAway) ? 1000 : 0;
            final extraPrice = (currentOption?.additionalPrice ?? 0) + packagingPrice;
            final unitPrice = product.price + extraPrice;
            final totalPrice = unitPrice * quantity;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 14,
                  bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 38,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Info Produk: Gambar, Nama, Kategori, Harga
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox(
                              width: 72,
                              height: 72,
                              child: Image.asset(
                                product.image.isNotEmpty
                                    ? product.image
                                    : AppAssets.breakfreeArenLatte,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: AppColors.cardBgColor,
                                  child: const Icon(
                                    Icons.restaurant_rounded,
                                    color: AppColors.primaryBrown,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  product.subcategory ?? product.category,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      AppFormatters.formatRupiah(unitPrice),
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkBrown,
                                      ),
                                    ),
                                    if (extraPrice > 0) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBrown
                                              .withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '+${AppFormatters.formatRupiah(extraPrice)}',
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryBrown,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (product.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          product.description,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.secondaryText,
                            height: 1.35,
                          ),
                        ),
                      ],

                      // ── PILIHAN VARIAN / OPSI PRODUK (Gyoza, Sarijan, Indomie) ──
                      if (optionGroup != null &&
                          optionGroup.options.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Divider(color: Colors.grey.shade200, height: 1),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Icon(
                              optionGroup.icon,
                              size: 18,
                              color: AppColors.primaryBrown,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              optionGroup.title,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '(Wajib pilih)',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(optionGroup.options.length,
                              (idx) {
                            final opt = optionGroup.options[idx];
                            final isSelected = idx == selectedOptionIndex;

                            return InkWell(
                              onTap: () {
                                setSheetState(() {
                                  selectedOptionIndex = idx;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryBrown
                                      : const Color(0xFFFAF7F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryBrown
                                        : AppColors.inputBorderColor,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primaryBrown
                                                .withOpacity(0.25),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected) ...[
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Text(
                                      opt.label,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.darkText,
                                      ),
                                    ),
                                    if (opt.additionalPrice > 0) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        ' (+${AppFormatters.formatRupiah(opt.additionalPrice)})',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.95)
                                              : AppColors.primaryBrown,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],

                      // ── PILIHAN KONSUMSI / PACKAGING KHUSUS MAKANAN (Dine In / Take Away +Rp 1.000) ──
                      if (isFood) ...[
                        const SizedBox(height: 16),
                        Divider(color: Colors.grey.shade200, height: 1),
                        const SizedBox(height: 14),
                        const Row(
                          children: [
                            Icon(
                              Icons.takeout_dining_rounded,
                              size: 18,
                              color: AppColors.primaryBrown,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Pilihan Penyajian Makanan',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            // Dine In
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setSheetState(() {
                                    isTakeAway = false;
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !isTakeAway
                                        ? AppColors.primaryBrown
                                        : const Color(0xFFFAF7F2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: !isTakeAway
                                          ? AppColors.primaryBrown
                                          : AppColors.inputBorderColor,
                                      width: !isTakeAway ? 1.5 : 1.0,
                                    ),
                                    boxShadow: !isTakeAway
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primaryBrown
                                                  .withOpacity(0.25),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.restaurant_rounded,
                                        size: 16,
                                        color: !isTakeAway
                                            ? Colors.white
                                            : AppColors.darkBrown,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Dine In',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: !isTakeAway
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: !isTakeAway
                                              ? Colors.white
                                              : AppColors.darkText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Take Away (+Rp 1.000)
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setSheetState(() {
                                    isTakeAway = true;
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isTakeAway
                                        ? AppColors.primaryBrown
                                        : const Color(0xFFFAF7F2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isTakeAway
                                          ? AppColors.primaryBrown
                                          : AppColors.inputBorderColor,
                                      width: isTakeAway ? 1.5 : 1.0,
                                    ),
                                    boxShadow: isTakeAway
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primaryBrown
                                                  .withOpacity(0.25),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 16,
                                        color: isTakeAway
                                            ? Colors.white
                                            : AppColors.darkBrown,
                                      ),
                                      const SizedBox(width: 6),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Take Away',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: isTakeAway
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                              color: isTakeAway
                                                  ? Colors.white
                                                  : AppColors.darkText,
                                            ),
                                          ),
                                          Text(
                                            '+Rp 1.000',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: isTakeAway
                                                  ? const Color(0xFFFFE082)
                                                  : AppColors.primaryBrown,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 16),
                      Divider(color: Colors.grey.shade200, height: 1),
                      const SizedBox(height: 14),

                      // ── Kuantitas (Tombol Plus, Minus, Jumlah Pcs) ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jumlah Pesanan',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Subtotal: ${AppFormatters.formatRupiah(totalPrice)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBrown,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F6F0),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: AppColors.inputBorderColor),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Tombol Minus (-)
                                InkWell(
                                  onTap: quantity > 1
                                      ? () {
                                          setSheetState(() {
                                            quantity--;
                                          });
                                        }
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: quantity > 1
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: quantity > 1
                                            ? AppColors.inputBorderColor
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.remove_rounded,
                                      size: 18,
                                      color: quantity > 1
                                          ? AppColors.darkText
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                ),

                                // Jumlah Pcs
                                Container(
                                  constraints:
                                      const BoxConstraints(minWidth: 44),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$quantity pcs',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                ),

                                // Tombol Plus (+)
                                InkWell(
                                  onTap: () {
                                    setSheetState(() {
                                      quantity++;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBrown,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.add_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Catatan untuk Kasir / Barista ──
                      Row(
                        children: [
                          const Icon(
                            Icons.edit_note_rounded,
                            size: 20,
                            color: AppColors.primaryBrown,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Catatan untuk Kasir',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(Opsional)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF7F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.inputBorderColor),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: TextField(
                          controller: noteController,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.darkText,
                          ),
                          decoration: const InputDecoration(
                            hintText:
                                'Contoh: Es dipisah, sambal banyakin, ekstra sedotan...',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: AppColors.hintColor,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── Tombol Tambah ke Keranjang ──
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(sheetCtx);
                            final note = noteController.text.trim();
                            final chosenOption = currentOption?.label;

                            String finalOption;
                            if (isFood) {
                              final packagingStr = isTakeAway ? 'Take Away' : 'Dine In';
                              if (chosenOption != null && chosenOption.isNotEmpty) {
                                finalOption = '$chosenOption • $packagingStr';
                              } else {
                                finalOption = packagingStr;
                              }
                            } else {
                              finalOption = chosenOption ?? (product.tag ?? (product.subcategory ?? 'Regular'));
                            }

                            CartService.instance.addProduct(
                              product,
                              options: finalOption,
                              customPrice: unitPrice,
                              quantity: quantity,
                              note: note,
                            );

                            final optionSuffix = ' ($finalOption)';

                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  quantity > 1
                                      ? '$quantity pcs ${product.name}$optionSuffix masuk ke keranjang belanja!'
                                      : '${product.name}$optionSuffix masuk ke keranjang belanja!',
                                ),
                                backgroundColor: AppColors.primaryBrown,
                                duration: const Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'Lihat',
                                  textColor: AppColors.buttonYellow,
                                  onPressed: () => Navigator.pushNamed(
                                      context, AppRoutes.cart),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBrown,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '+ Tambah ke Keranjang • ${AppFormatters.formatRupiah(totalPrice)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(noteController.dispose);
  }
}
