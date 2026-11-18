import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../cart/domain/services/cart_service.dart';
import '../../../home/domain/models/product_model.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../../home/presentation/widgets/home_nav_helper.dart';
import '../../domain/services/user_service.dart';

class PointRedemptionItem {
  final String id;
  final String name;
  final String image;
  final int originalPrice;
  final int pointsCost;
  final int discountAmount;
  final int finalPrice;

  const PointRedemptionItem({
    required this.id,
    required this.name,
    required this.image,
    required this.originalPrice,
    required this.pointsCost,
    required this.discountAmount,
    required this.finalPrice,
  });
}

class CashbackPointsPage extends StatefulWidget {
  const CashbackPointsPage({super.key});

  @override
  State<CashbackPointsPage> createState() => _CashbackPointsPageState();
}

class _CashbackPointsPageState extends State<CashbackPointsPage> {
  final List<PointRedemptionItem> _items = const [
    PointRedemptionItem(
      id: 'point-1',
      name: 'Ice Kopi Susu',
      image: AppAssets.breakfreeArenLatte,
      originalPrice: 16000,
      pointsCost: 400,
      discountAmount: 4000,
      finalPrice: 12000,
    ),
    PointRedemptionItem(
      id: 'point-2',
      name: 'Breakfree Aren Latte',
      image: AppAssets.breakfreeArenLatte,
      originalPrice: 18000,
      pointsCost: 500,
      discountAmount: 5000,
      finalPrice: 13000,
    ),
    PointRedemptionItem(
      id: 'point-3',
      name: 'Caramel Macchiato',
      image: AppAssets.caramelMacchiato,
      originalPrice: 20000,
      pointsCost: 600,
      discountAmount: 6000,
      finalPrice: 14000,
    ),
    PointRedemptionItem(
      id: 'point-4',
      name: 'Signature Matcha',
      image: AppAssets.cubeMoca,
      originalPrice: 18000,
      pointsCost: 500,
      discountAmount: 5000,
      finalPrice: 13000,
    ),
  ];

  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = _items.first.id;
  }

  void _onRedeemPoints(PointRedemptionItem item, int userPoints) {
    if (userPoints < item.pointsCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Poin kamu tidak mencukupi untuk menu ini.'),
          backgroundColor: Color(0xFFD32F2F),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final success = UserService.instance.deductPoints(item.pointsCost);
    if (!success) return;

    // Masukkan ke keranjang dengan harga diskon poin
    final product = ProductModel(
      id: item.id,
      name: item.name,
      price: item.finalPrice,
      category: 'kopi',
      image: item.image,
    );

    CartService.instance.addProduct(
      product,
      customPrice: item.finalPrice,
      options: 'Potongan ${item.pointsCost} Poin',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Berhasil memakai ${item.pointsCost} poin untuk ${item.name}!',
        ),
        backgroundColor: AppColors.primaryBrown,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Lihat',
          textColor: AppColors.buttonYellow,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([UserService.instance, CartService.instance]),
      builder: (context, _) {
        final user = UserService.instance;
        final cartCount = CartService.instance.totalItemCount;
        final selectedItem =
            _items.firstWhere((it) => it.id == _selectedId, orElse: () => _items.first);
        final remainingPoints = user.points - selectedItem.pointsCost;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // ══════════════════════ HEADER ══════════════════════
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.inputBorderColor,
                            width: 1.0,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: AppColors.darkText,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Cashback & Poin',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ══════════════════════ SCROLLABLE CONTENT ══════════════════════
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),

                        // ── Kartu Saldo Poin ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF635247),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    user.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withAlpha(230),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.promoBadgeColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      user.memberBadge,
                                      style: const TextStyle(
                                        color: Color(0xFF4A3000),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Saldo poin kamu',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withAlpha(200),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        AppFormatters.formatThousands(
                                            user.points),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'poin',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withAlpha(210),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Coin Avatar Icon
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: const BoxDecoration(
                                      color: AppColors.promoBadgeColor,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Transform.translate(
                                          offset: const Offset(-5, -3),
                                          child: Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 1.8,
                                              ),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'c',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Transform.translate(
                                          offset: const Offset(4, 3),
                                          child: Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              color: AppColors.promoBadgeColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 1.8,
                                              ),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'c',
                                                style: TextStyle(
                                                  fontSize: 11,
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
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ── Subtitle Info Poin ──
                        const Text(
                          'Cashback berupa poin untuk potongan harga menu, bukan uang tunai.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          '100 poin = potongan Rp 1.000',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ── Section Title ──
                        const Text(
                          'Pilih menu, pakai poinmu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Pilih satu menu untuk simulasi potongan harga.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.secondaryText,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ── Daftar Pilihan Menu ──
                        ..._items.map((item) {
                          final isSelected = item.id == _selectedId;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedId = item.id;
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryBrown
                                        : AppColors.inputBorderColor,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Row Atas: Foto, Info Nama & Radio Check
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: SizedBox(
                                            width: 62,
                                            height: 62,
                                            child: Image.asset(
                                              item.image,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: const TextStyle(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.darkText,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Harga asli ',
                                                    style: TextStyle(
                                                      fontSize: 11.5,
                                                      color: AppColors
                                                          .secondaryText,
                                                    ),
                                                  ),
                                                  Text(
                                                    AppFormatters.formatRupiah(
                                                        item.originalPrice),
                                                    style: const TextStyle(
                                                      fontSize: 11.5,
                                                      color: AppColors
                                                          .secondaryText,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                'Gunakan ${item.pointsCost} poin',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.darkBrown,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Radio check indicator
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected
                                                ? AppColors.primaryBrown
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primaryBrown
                                                  : const Color(0xFFD6CEC6),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),
                                    const Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: AppColors.inputBorderColor,
                                    ),
                                    const SizedBox(height: 10),

                                    // Row Bawah: Potongan Harga & Setelah Potongan
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Potongan harga',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '- ${AppFormatters.formatRupiah(item.discountAmount)}',
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.darkText,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              'Setelah potongan',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              AppFormatters.formatRupiah(
                                                  item.finalPrice),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.darkText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // ══════════════════════ BOTTOM BAR ══════════════════════
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.inputBorderColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedItem.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${selectedItem.pointsCost} poin dipakai • Sisa ${remainingPoints < 0 ? 0 : remainingPoints} poin',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            AppFormatters.formatRupiah(selectedItem.finalPrice),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () =>
                              _onRedeemPoints(selectedItem, user.points),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBrown,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.confirmation_number_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Gunakan ${selectedItem.pointsCost} Poin',
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: HomeBottomNavBar(
            currentIndex: 3,
            orderBadgeCount: cartCount,
            onTap: (index) => handleSecondaryBottomNavTap(
              context,
              index,
              currentIndex: 3,
            ),
          ),
        );
      },
    );
  }
}

