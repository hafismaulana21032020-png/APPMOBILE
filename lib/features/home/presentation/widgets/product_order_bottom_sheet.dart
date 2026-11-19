import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../cart/domain/services/cart_service.dart';
import '../../domain/models/product_model.dart';

/// Modal bottom sheet interaktif untuk memilih jumlah pcs dan menambahkan catatan ke kasir.
class ProductOrderBottomSheet {
  ProductOrderBottomSheet._();

  static void show(BuildContext context, ProductModel product) {
    int quantity = 1;
    final noteController = TextEditingController();

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
            final totalPrice = product.price * quantity;

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
                                    Icons.coffee_rounded,
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
                                  product.tag != null
                                      ? '${product.name} (${product.tag})'
                                      : product.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.subcategory ?? product.category,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.formattedPrice,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkBrown,
                                  ),
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
                            fontSize: 13,
                            color: AppColors.secondaryText,
                            height: 1.4,
                          ),
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
                              border: Border.all(color: AppColors.inputBorderColor),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                                      color: quantity > 1 ? Colors.white : Colors.transparent,
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
                                  constraints: const BoxConstraints(minWidth: 44),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: TextField(
                          controller: noteController,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.darkText,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Contoh: Kurangi gula, es dipisah, ekstra sedotan...',
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
                            CartService.instance.addProduct(
                              product,
                              quantity: quantity,
                              note: note,
                            );
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  quantity > 1
                                      ? '$quantity pcs ${product.name} masuk ke keranjang belanja!'
                                      : '${product.name} masuk ke keranjang belanja!',
                                ),
                                backgroundColor: AppColors.primaryBrown,
                                duration: const Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'Lihat',
                                  textColor: AppColors.buttonYellow,
                                  onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
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
    );
  }
}
