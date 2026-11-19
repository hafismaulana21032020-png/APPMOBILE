import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../domain/models/cart_item_model.dart';
import '../../domain/services/cart_service.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../account/domain/services/user_service.dart';
import '../../../order/domain/services/order_service.dart';
import '../widgets/cart_item_card.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late final TextEditingController _promoController;

  List<CartItemModel> get _cartItems => CartService.instance.items;

  // Promo terpasang
  bool _isPromoApplied = false;
  String? _appliedCode;
  final double _discountPercent = 0.20;

  // Metode Pembayaran Terpilih (Hanya QRIS & Cash)
  String _selectedPaymentMethod = 'QRIS';
  final List<String> _paymentMethods = ['QRIS', 'Cash'];

  @override
  void initState() {
    super.initState();
    final savedCode = CartService.instance.appliedPromoCode;
    _appliedCode = savedCode;
    _isPromoApplied = savedCode != null && savedCode.isNotEmpty;
    _promoController = TextEditingController(
      text: savedCode != null ? 'KODE PROMO: $savedCode' : '',
    );
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  int get _subtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get _discountAmount {
    if (!_isPromoApplied) return 0;
    if (_appliedCode == 'BREAK20') {
      if (_subtotal < 30000) return 0;
      final discount = (_subtotal * _discountPercent).round();
      return discount > 10000 ? 10000 : discount;
    }
    return (_subtotal * _discountPercent).round();
  }

  int get _totalPayment {
    final total = _subtotal - _discountAmount;
    return total > 0 ? total : 0;
  }

  String _formatPrice(int price) => AppFormatters.formatRupiah(price);

  void _onIncrement(int index) {
    CartService.instance.increment(index);
  }

  void _onDecrement(int index) {
    if (index < 0 || index >= _cartItems.length) return;
    final item = _cartItems[index];
    if (item.quantity > 1) {
      CartService.instance.decrement(index);
    } else {
      // Tampilkan konfirmasi hapus item
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hapus Item?'),
          content: Text(
              'Apakah Anda ingin menghapus ${item.name} dari keranjang?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                CartService.instance.removeById(item.id);
              },
              child: const Text('Hapus',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }

  void _applyPromo() {
    final rawCode = _promoController.text.trim().toUpperCase();
    final normalizedCode = rawCode
        .replaceFirst(RegExp(r'^KODE\s*PROMO\s*:\s*'), '')
        .trim();

    if (normalizedCode == 'KOPIKAMPUS' || normalizedCode == 'BREAK20') {
      setState(() {
        _isPromoApplied = true;
        _appliedCode = normalizedCode;
      });
      CartService.instance.applyPromoCode(normalizedCode);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            normalizedCode == 'BREAK20'
                ? 'Voucher BREAK20 berhasil diterapkan! (Diskon 20%, maks. Rp 10.000)'
                : 'Promo KOPIKAMPUS berhasil diterapkan! (Diskon 20%)',
          ),
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (normalizedCode.isEmpty) {
      setState(() {
        _isPromoApplied = false;
        _appliedCode = null;
      });
      CartService.instance.applyPromoCode(null);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode promo dihapus'),
          backgroundColor: AppColors.primaryBrown,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode promo tidak valid'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onCheckout() {
    if (_cartItems.isEmpty) return;
    if (_selectedPaymentMethod == 'QRIS') {
      _showQrisBottomSheet();
    } else {
      _showCashConfirmDialog();
    }
  }

  void _showQrisBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  const Text(
                    'Pembayaran QRIS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Scan kode QRIS di bawah ini untuk membayar',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Total Tagihan
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F6F0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.inputBorderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        Text(
                          _formatPrice(_totalPayment),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Gambar QRIS Resmi yang sudah diproses & bersih
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.inputBorderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        AppAssets.qrisBreakfree,
                        height: 310,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_rounded, size: 15, color: Color(0xFF2E7D32)),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Mendukung semua Bank (BSI, BCA, BRI, dll) & e-Wallet',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Tombol Konfirmasi Pembayaran
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _executeCheckout('QRIS');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Saya Sudah Membayar',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText,
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
  }

  void _showCashConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.payments_rounded, color: AppColors.primaryBrown, size: 24),
            SizedBox(width: 8),
            Text(
              'Bayar Tunai di Kasir',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pesanan kamu akan dibuat dengan status Menunggu Pembayaran.',
              style: TextStyle(fontSize: 13, color: AppColors.darkText, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total yang harus dibayar di kasir:',
                    style: TextStyle(fontSize: 11, color: Color(0xFF795548)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatPrice(_totalPayment),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Silakan sebutkan nomor antrean ke kasir untuk membayar. Begitu kasir konfirmasi, barista akan segera meracik pesananmu.',
              style: TextStyle(fontSize: 11.5, color: AppColors.secondaryText, height: 1.35),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _executeCheckout('Cash');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text(
              'Pesan Sekarang',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _executeCheckout(String paymentMethod) async {
    final total = _totalPayment;
    final promoCode = CartService.instance.appliedPromoCode;
    final cartItems = List<CartItemModel>.from(CartService.instance.items);

    // Buat live order di OrderService dan sinkronkan ke backend Web POS
    final newOrder = await OrderService.instance.createOrderFromCart(
      items: cartItems,
      paymentMethod: paymentMethod,
      totalPrice: total,
      promoCode: promoCode,
    );

    // Setiap pembelian menggunakan aplikasi mendapatkan cashback poin
    final earnedPoints = (total >= 40000 ? 100 : 50);
    UserService.instance.addPoints(earnedPoints);

    // Bersihkan keranjang
    CartService.instance.clear();

    if (!mounted) return;

    // Navigate ke halaman pembayaran berhasil
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.paymentSuccess,
      (route) => false,
      arguments: {
        'orderNumber': newOrder.id,
        'queueNumber': newOrder.queueNumber,
        'paymentMethod': paymentMethod,
        'totalPayment': total,
        'earnedPoints': earnedPoints,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartService.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                      'Keranjang Belanja',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================= SCROLLABLE CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),

                    // Daftar Item Keranjang
                    if (_cartItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'Keranjang Anda masih kosong',
                            style: TextStyle(color: AppColors.secondaryText),
                          ),
                        ),
                      )
                    else
                      ...List.generate(_cartItems.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: CartItemCard(
                            item: _cartItems[index],
                            onIncrement: () => _onIncrement(index),
                            onDecrement: () => _onDecrement(index),
                          ),
                        );
                      }),

                    const SizedBox(height: 6),

                    // Input Kode Promo & Tombol Terapkan
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.inputBorderColor,
                                width: 1.0,
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              controller: _promoController,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                                letterSpacing: 0.3,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'KODE PROMO',
                                hintStyle: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.hintColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _applyPromo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBrown,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                            ),
                            child: const Text(
                              'Terapkan',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section Metode Pembayaran
                    const Text(
                      'Metode Pembayaran',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Row Pilihan Pembayaran (QRIS, Cash)
                    Row(
                      children: _paymentMethods.map((method) {
                        final isSelected = _selectedPaymentMethod == method;
                        final isQris = method == 'QRIS';
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPaymentMethod = method;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.buttonYellow
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFC9A254)
                                        : AppColors.inputBorderColor,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.buttonYellow.withAlpha(80),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isQris
                                          ? Icons.qr_code_2_rounded
                                          : Icons.payments_rounded,
                                      size: 20,
                                      color: AppColors.darkBrown,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        isQris ? 'QRIS' : 'Cash (Kasir)',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: AppColors.darkBrown,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ================= BOTTOM SUMMARY & CHECKOUT BAR =================
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFF0EBE5),
                    width: 1.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Subtotal',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatPrice(_subtotal),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Diskon Promo
                  if (_isPromoApplied) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Diskon Promo',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F9D58),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '-${_formatPrice(_discountAmount)}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F9D58),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Total Pembayaran
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatPrice(_totalPayment),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Tombol Bayar Sekarang
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _cartItems.isEmpty ? null : _onCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrown,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _selectedPaymentMethod == 'Cash'
                              ? 'Pesan & Bayar di Kasir (${_formatPrice(_totalPayment)})'
                              : 'Bayar via QRIS (${_formatPrice(_totalPayment)})',
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 15,
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
      ),
        );
      },
    );
  }
}

