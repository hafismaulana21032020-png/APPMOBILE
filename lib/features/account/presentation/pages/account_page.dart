import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../cart/domain/services/cart_service.dart';
import '../../../home/presentation/controllers/home_tab_controller.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../../home/presentation/widgets/home_nav_helper.dart';
import '../../domain/services/user_service.dart';
import '../../../order/domain/services/order_service.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: Color(0xFFD32F2F),
              size: 22,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Keluar dari Akun?',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari akun BreakFree? Kamu perlu masuk kembali untuk mengakses pesanan dan poin cashback-mu.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.secondaryText,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              HomeTabController.instance.resetToHome();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (r) => false,
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kamu telah berhasil keluar dari akun.'),
                  backgroundColor: AppColors.primaryBrown,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
        final trimmedName = user.name.trim();
        final firstName = trimmedName.isEmpty
            ? 'PENGGUNA'
            : trimmedName.split(RegExp(r'\s+')).first.toUpperCase();

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ══════════════════════ HEADER BAR ══════════════════════
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 16, 18, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BreakFree',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBrown,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          'Akun Saya',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ══════════════════════ BANNER CARD ══════════════════════
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _BannerCard(firstName: firstName),
                  ),

                  const SizedBox(height: 14),

                  // ══════════════ PROFILE CARD (HM + name + badge) ══════════════
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.profile),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.inputBorderColor, width: 1),
                        ),
                        child: Row(
                          children: [
                            // Initials avatar
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBrown,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                user.initials,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkText,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.buttonYellow,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      user.memberBadge,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.darkBrown,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ══════════════════ STATS ROW (Poin · Pesanan · Promo) ══════════════════
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.inputBorderColor, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            _StatItem(
                              label: 'Poin',
                              value: AppFormatters.formatThousands(user.points),
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.cashbackPoints,
                              ),
                            ),
                            const VerticalDivider(
                              color: AppColors.inputBorderColor,
                              thickness: 1,
                              width: 1,
                            ),
                            const _StatItem(label: 'Pesanan', value: '12'),
                            const VerticalDivider(
                              color: AppColors.inputBorderColor,
                              thickness: 1,
                              width: 1,
                            ),
                            const _StatItem(label: 'Promo', value: '3'),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ══════════════════ QUICK ACTIONS (3 tiles) ══════════════════
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        _QuickAction(
                          icon: Icons.receipt_long_rounded,
                          label: 'Pesanan\nSaya',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.orderTracking),
                        ),
                        const SizedBox(width: 10),
                        _QuickAction(
                          icon: Icons.savings_rounded,
                          label: 'Cashback\npoin',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.cashbackPoints,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _QuickAction(
                          icon: Icons.favorite_border_rounded,
                          label: 'Favorit',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Menu favoritmu tersimpan di katalog BreakFree.'),
                                backgroundColor: AppColors.primaryBrown,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ══════════════════ LACAK PESANAN BUTTON ══════════════════
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.orderTracking,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBrown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Lacak Pesanan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ══════════════════ TRANSAKSI TERBARU ══════════════════
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Transaksi terbaru',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.orderTracking,
                              arguments: 1,
                            );
                          },
                          child: const Text(
                            'Riwayat',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: AnimatedBuilder(
                      animation: OrderService.instance,
                      builder: (context, _) {
                        final history = OrderService.instance.orderHistory;
                        if (history.isEmpty) {
                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.inputBorderColor, width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 24),
                            child: const Center(
                              child: Text(
                                'Belum ada transaksi',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                          );
                        }

                        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
                        final displayItems = history.take(3).toList();
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.inputBorderColor, width: 1),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Column(
                            children: List.generate(displayItems.length, (idx) {
                              final item = displayItems[idx];
                              final m = item.createdAt.month;
                              final mName = (m >= 1 && m <= 12) ? months[m - 1] : '';
                              final dateStr =
                                  '${item.createdAt.day} $mName · ${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')} · ${item.items.length} Item';
                              return Column(
                                children: [
                                  if (idx > 0)
                                    const Divider(
                                        height: 1,
                                        color: AppColors.inputBorderColor),
                                  _TransactionTile(
                                    orderId: item.id,
                                    dateTime: dateStr,
                                    amount: item.totalPrice,
                                    status: item.status.title,
                                  ),
                                ],
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ══════════════════ MENU LIST ══════════════════
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.inputBorderColor, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        children: [
                          _MenuItem(
                            icon: Icons.person_outline_rounded,
                            title: 'Profil Akun',
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.profile),
                          ),
                          const Divider(
                              height: 1, color: AppColors.inputBorderColor),
                          _MenuItem(
                            icon: Icons.logout_rounded,
                            title: 'Keluar akun',
                            iconColor: const Color(0xFFD32F2F),
                            titleColor: const Color(0xFFD32F2F),
                            onTap: () => _showLogoutDialog(context),
                          ),
                          const Divider(
                              height: 1, color: AppColors.inputBorderColor),
                          _MenuItem(
                            icon: Icons.notifications_none_rounded,
                            title: 'Notifikasi',
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.notifications),
                          ),
                          const Divider(
                              height: 1, color: AppColors.inputBorderColor),
                          _MenuItem(
                            icon: Icons.settings_outlined,
                            title: 'Pengaturan',
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.settings),
                          ),
                          const Divider(
                              height: 1, color: AppColors.inputBorderColor),
                          _MenuItem(
                            icon: Icons.help_outline_rounded,
                            title: 'Bantuan',
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.help),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
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

// ─────────────── LOCAL WIDGETS ───────────────

class _BannerCard extends StatelessWidget {
  final String firstName;

  const _BannerCard({required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkBrown,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AppAssets.coffeeBanner,
                fit: BoxFit.cover,
                color: const Color(0xCC2A1A0F),
                colorBlendMode: BlendMode.multiply,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: AppColors.darkBrown),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge AKUN AKTIF
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.promoBadgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'AKUN AKTIF',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A3000),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Selamat datang kembali',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    firstName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola profil, pesanan, dan preferensi akunku\ndengan lebih mudah',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withAlpha(179),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _StatItem({
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.inputBorderColor, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cardBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20, color: AppColors.primaryBrown),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String orderId;
  final String dateTime;
  final int amount;
  final String status;

  const _TransactionTile({
    required this.orderId,
    required this.dateTime,
    required this.amount,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.orderTracking,
          arguments: 1,
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.cardBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.receipt_rounded,
              size: 18,
              color: AppColors.primaryBrown,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderId,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateTime,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.formatRupiah(amount),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF388E3C),
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

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? AppColors.primaryBrown,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? AppColors.darkText,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: iconColor ?? AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}
