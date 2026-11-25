import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../domain/models/cart_item_model.dart';
import '../../domain/services/cart_service.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../account/domain/services/user_service.dart';
import '../../../home/domain/services/pickup_mode_service.dart';
import '../../../home/domain/services/menu_service.dart';
import '../../../home/domain/services/promo_service.dart';
import '../../../order/domain/services/order_service.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/midtrans_payment_sheet.dart';

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
  int? _validatedDiscountAmount;
  final double _discountPercent = 0.20;

  bool get _hasUnavailableItem =>
      _cartItems.any((item) => MenuService.instance.isSoldOut(item.id, item.name));

  // Metode Pembayaran Terpilih (Midtrans Online QRIS/VA & Cash)
  String _selectedPaymentMethod = 'QRIS';
  final List<String> _paymentMethods = ['QRIS', 'Cash'];

  // Toggle Pemakaian Poin Cashback BreakFree
  bool _usePoints = false;
  bool _isSubmittingCheckout = false;

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
    if (_validatedDiscountAmount != null) return _validatedDiscountAmount!;
    if (_appliedCode == 'BREAK20') {
      if (_subtotal < 30000) return 0;
      final discount = (_subtotal * _discountPercent).round();
      return discount > 10000 ? 10000 : discount;
    }
    return (_subtotal * _discountPercent).round();
  }

  // Kalkulasi Aturan Poin Single Source of Truth:
  // - 100 poin = Rp 1.000 (1 poin = Rp 10)
  // - Kelipatan 100 poin, minimal 100 poin
  // - Maksimal diskon 25% dari subtotal, dibulatkan ke bawah per Rp 1.000
  int get _userPoints => UserService.instance.points;
  int get _usablePoints => (_userPoints ~/ 100) * 100;
  int get _maxPointsDiscount => ((_subtotal * 0.25) ~/ 1000) * 1000;

  int get _potentialPointsToUse {
    if (_userPoints < 100 || _subtotal <= 0) return 0;
    final maxPointsAllowed = _maxPointsDiscount ~/ 10;
    return math.min(maxPointsAllowed, _usablePoints);
  }

  int get _potentialDiscountAmount => _potentialPointsToUse * 10;

  int get _pointsToUse => _usePoints ? _potentialPointsToUse : 0;
  int get _pointDiscountAmount => _pointsToUse * 10;

  // PPN 10% dari pesanan
  int get _taxAmount => (_subtotal * 0.10).round();

  int get _totalPayment {
    final payableSubtotal = _subtotal - _discountAmount - (_usePoints ? _pointDiscountAmount : 0);
    final total = (payableSubtotal > 0 ? payableSubtotal : 0) + _taxAmount;
    return total > 0 ? total : 0;
  }

  // Earning Cashback 5%: Math.floor(payableSubtotal / 1000) * 5
  int get _earnedCashbackPoints {
    final payable = _subtotal - (_usePoints ? _pointDiscountAmount : 0) - _discountAmount;
    if (payable <= 0) return 0;
    return (payable ~/ 1000) * 5;
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

  void _applyPromo() async {
    final rawCode = _promoController.text.trim().toUpperCase();
    final normalizedCode = rawCode
        .replaceFirst(RegExp(r'^KODE\s*PROMO\s*:\s*'), '')
        .trim();

    if (normalizedCode.isEmpty) {
      setState(() {
        _isPromoApplied = false;
        _appliedCode = null;
        _validatedDiscountAmount = null;
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
      return;
    }

    // Validasi langsung ke backend Express (tabel MySQL discounts)
    final res = await PromoService.instance.validateCode(normalizedCode, _subtotal);
    if (!mounted) return;

    if (res['valid'] == true) {
      final discountAmt = res['discountAmount'] is num
          ? (res['discountAmount'] as num).toInt()
          : null;
      setState(() {
        _isPromoApplied = true;
        _appliedCode = normalizedCode;
        _validatedDiscountAmount = discountAmt;
      });
      CartService.instance.applyPromoCode(normalizedCode);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res['message']?.toString() ??
                'Voucher $normalizedCode berhasil diterapkan!',
          ),
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Fallback lokal jika offline
      if (normalizedCode == 'BREAK20' && _subtotal >= 30000) {
        setState(() {
          _isPromoApplied = true;
          _appliedCode = normalizedCode;
          _validatedDiscountAmount = null;
        });
        CartService.instance.applyPromoCode(normalizedCode);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voucher BREAK20 berhasil diterapkan! (Diskon 20%, maks. Rp 10.000)'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['message']?.toString() ??
                  'Kode promo tidak valid atau syarat belanja belum terpenuhi.',
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _onCheckout() {
    if (_cartItems.isEmpty || _isSubmittingCheckout) return;
    if (_hasUnavailableItem) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terdapat menu yang sedang habis. Hapus menu tersebut sebelum checkout.'),
          backgroundColor: Color(0xFFC93B2B),
        ),
      );
      return;
    }
    if (_selectedPaymentMethod == 'QRIS') {
      _executeCheckout('MIDTRANS');
    } else {
      _showCashConfirmDialog();
    }
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
    if (_isSubmittingCheckout) return;
    setState(() => _isSubmittingCheckout = true);

    final total = _totalPayment;
    final promoCode = CartService.instance.appliedPromoCode;
    final cartItems = List<CartItemModel>.from(CartService.instance.items);

    final orderType = PickupModeService.instance.mode.code;
    final pickupType = PickupModeService.instance.isTakeaway
        ? 'Takeaway (Bungkus Bawa Pulang)'
        : 'Dine-in (Minum di Kafe)';

    final isCash = paymentMethod.toLowerCase().contains('cash') ||
        paymentMethod.toLowerCase().contains('tunai');

    // Buat live order di OrderService dan sinkronkan ke backend + Midtrans
    try {
      final newOrder = await OrderService.instance.createOrderFromCart(
        items: cartItems,
        paymentMethod: paymentMethod,
        totalPrice: total,
        promoCode: promoCode,
        orderType: orderType,
        pickupType: pickupType,
        usePoints: _usePoints,
      );

      final pointsData = newOrder.points;
      if (pointsData != null && pointsData['currentBalance'] != null) {
        UserService.instance.setPoints(pointsData['currentBalance']);
      } else if (_usePoints && _pointsToUse > 0) {
        UserService.instance.deductPoints(_pointsToUse);
      }

      // Bersihkan keranjang karena pesanan sudah tersimpan aman di MySQL
      CartService.instance.clear();

      if (!mounted) return;
      setState(() => _isSubmittingCheckout = false);

      if (!isCash && newOrder.snapRedirectUrl != null) {
        await MidtransPaymentSheet.show(
          context,
          order: newOrder,
          onPaid: (statusRes) {
            if (!mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.paymentSuccess,
              (route) => false,
              arguments: {
                'orderNumber': newOrder.id,
                'queueNumber': newOrder.queueNumber,
                'paymentMethod':
                    statusRes['paymentMethodLabel']?.toString() ?? 'Midtrans',
                'totalPayment': newOrder.totalPrice,
                'points': {
                  'earned': newOrder.pointsEarned > 0
                      ? newOrder.pointsEarned
                      : _earnedCashbackPoints,
                  'used': newOrder.pointsUsed,
                  'discountAmount': newOrder.pointsDiscount,
                  'currentBalance': UserService.instance.points,
                  'isPending': false,
                },
              },
            );
          },
          onFailed: (errMsg) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errMsg),
                backgroundColor: const Color(0xFFC93B2B),
                duration: const Duration(seconds: 4),
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.orderTracking,
              (route) => false,
            );
          },
          onPayLater: () {
            if (!mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.orderTracking,
              (route) => false,
            );
          },
        );
        return;
      }

      // Alur pembayaran Cash di kasir
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.paymentSuccess,
        (route) => false,
        arguments: {
          'orderNumber': newOrder.id,
          'queueNumber': newOrder.queueNumber,
          'paymentMethod': paymentMethod,
          'totalPayment': total,
          'points': pointsData ?? {
            'earned': _earnedCashbackPoints,
            'used': _pointsToUse,
            'discountAmount': _pointDiscountAmount,
            'currentBalance': UserService.instance.points,
            'isPending': true,
          },
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmittingCheckout = false);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: const Color(0xFFC93B2B),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        CartService.instance,
        PickupModeService.instance,
        MenuService.instance,
      ]),
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

                    // Pemilih Mode Pengambilan (Dine-in Self Pick-Up vs Takeaway)
                    AnimatedBuilder(
                      animation: PickupModeService.instance,
                      builder: (context, _) {
                        final isDineIn = PickupModeService.instance.isDineIn;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardBgColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.inputBorderColor,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.storefront_outlined,
                                    size: 16,
                                    color: AppColors.primaryBrown,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Metode Pengambilan Pesanan',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkBrown,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        PickupModeService.instance.setMode(
                                          PickupMode.dineIn,
                                        );
                                      }),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDineIn
                                              ? AppColors.primaryBrown
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: isDineIn
                                                ? AppColors.primaryBrown
                                                : AppColors.inputBorderColor,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.local_cafe_outlined,
                                              size: 16,
                                              color: isDineIn
                                                  ? Colors.white
                                                  : AppColors.darkBrown,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                'Dine-in (Self Pick-Up)',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDineIn
                                                      ? Colors.white
                                                      : AppColors.darkBrown,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        PickupModeService.instance.setMode(
                                          PickupMode.takeaway,
                                        );
                                      }),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: !isDineIn
                                              ? AppColors.primaryBrown
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: !isDineIn
                                                ? AppColors.primaryBrown
                                                : AppColors.inputBorderColor,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.shopping_bag_outlined,
                                              size: 16,
                                              color: !isDineIn
                                                  ? Colors.white
                                                  : AppColors.darkBrown,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                'Takeaway (Bawa Pulang)',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: !isDineIn
                                                      ? Colors.white
                                                      : AppColors.darkBrown,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Peringatan jika ada item habis di keranjang
                    if (_hasUnavailableItem)
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFCDD2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.error_outline_rounded, color: Color(0xFFC62828), size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Ada menu di keranjang yang saat ini habis (sold out). Hapus menu tersebut agar dapat melanjutkan pesanan.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFFC62828),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

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
                        final it = _cartItems[index];
                        final isUnavail = MenuService.instance.isSoldOut(it.id, it.name);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: CartItemCard(
                            item: it,
                            isUnavailable: isUnavail,
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
                                        isQris ? 'Midtrans (QRIS/VA)' : 'Cash (Kasir)',
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

                    const SizedBox(height: 18),

                    // ================= KARTU PAKAI POIN BREAKFREE =================
                    AnimatedBuilder(
                      animation: UserService.instance,
                      builder: (context, _) {
                        final canRedeem = _userPoints >= 100 && _potentialPointsToUse > 0;
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _usePoints ? AppColors.primaryBrown : AppColors.inputBorderColor,
                              width: _usePoints ? 1.5 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8E1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.stars_rounded,
                                      color: Color(0xFFFFB300),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          spacing: 6,
                                          runSpacing: 2,
                                          children: [
                                            const Text(
                                              'Pakai Poin BreakFree',
                                              style: TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.darkText,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.cardBgColor,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '$_userPoints Poin',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryBrown,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _userPoints < 100
                                              ? 'Minimal 100 poin untuk dapat ditukarkan'
                                              : (_usePoints
                                                  ? 'Gunakan $_pointsToUse poin (Hemat ${_formatPrice(_pointDiscountAmount)})'
                                                  : 'Gunakan $_potentialPointsToUse poin (Hemat ${_formatPrice(_potentialDiscountAmount)})'),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _userPoints < 100 ? Colors.grey : AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: _usePoints && canRedeem,
                                    activeColor: AppColors.primaryBrown,
                                    activeTrackColor: AppColors.cardBgColor,
                                    onChanged: canRedeem
                                        ? (val) {
                                            setState(() {
                                              _usePoints = val;
                                            });
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Banner Estimasi Cashback
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F8E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.card_giftcard_rounded,
                                      size: 16,
                                      color: Color(0xFF2E7D32),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '+$_earnedCashbackPoints Poin Cashback akan kamu dapatkan',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
                    const SizedBox(height: 6),
                  ],

                  // Potongan Poin BreakFree
                  if (_usePoints && _pointDiscountAmount > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Potongan Poin BreakFree',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F9D58),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '-${_formatPrice(_pointDiscountAmount)}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F9D58),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],

                  // PPN 10% dari pesanan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'PPN (10%)',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatPrice(_taxAmount),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

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
                      onPressed: (_cartItems.isEmpty || _hasUnavailableItem || _isSubmittingCheckout) ? null : _onCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrown,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmittingCheckout
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _hasUnavailableItem
                                    ? 'Hapus Menu Habis untuk Melanjutkan'
                                    : _selectedPaymentMethod == 'Cash'
                                        ? 'Pesan & Bayar di Kasir (${_formatPrice(_totalPayment)})'
                                        : 'Bayar via Midtrans (${_formatPrice(_totalPayment)})',
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

