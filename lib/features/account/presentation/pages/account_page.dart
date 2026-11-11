import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cart/domain/services/cart_service.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../domain/services/user_service.dart';
import '../widgets/account_banner_card.dart';
import '../widgets/account_menu_item.dart';
import '../widgets/account_profile_card.dart';
import '../widgets/account_quick_actions.dart';
import '../widgets/account_stats_row.dart';
import '../widgets/transaction_item_tile.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([UserService.instance, CartService.instance]),
      builder: (context, _) {
        final user = UserService.instance;
        final cartCount = CartService.instance.totalItemCount;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BreakFree',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBrown,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Akun Saya',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 24,
                        color: AppColors.darkBrown,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Banner Card
                  AccountBannerCard(
                    userName: user.name.split(' ').first.toUpperCase(),
                  ),
                  const SizedBox(height: 14),

                  // Profile Card
                  AccountProfileCard(
                    initials: user.initials,
                    name: user.name,
                    email: user.email,
                    memberBadge: user.memberBadge,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                  ),
                  const SizedBox(height: 10),

                  // Stats Row
                  const AccountStatsRow(poin: 1240, pesanan: 12, promo: 3),
                  const SizedBox(height: 10),

                  // Quick Actions (order tap navigates to cart)
                  AccountQuickActions(
                    onOrderTap: () =>
                        Navigator.pushNamed(context, AppRoutes.cart),
                    onCashbackTap: null,
                    onFavoriteTap: null,
                  ),
                  const SizedBox(height: 14),

                  // Lacak Pesanan Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Lacak Pesanan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Transaksi terbaru
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Transaksi terbaru',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        'Riwayat',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBrown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.inputBorderColor,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      children: const [
                        TransactionItemTile(
                          orderId: '#BF-0302',
                          dateTime: '28 Jun · 19:41 · 3 Item · 2025',
                          amount: 45000,
                          status: 'Selesai',
                        ),
                        Divider(height: 1, color: AppColors.inputBorderColor),
                        TransactionItemTile(
                          orderId: '#BF-0297',
                          dateTime: '21 Jun · 12:36 · 1 Item · 16 May',
                          amount: 62000,
                          status: 'Selesai',
                        ),
                        Divider(height: 1, color: AppColors.inputBorderColor),
                        TransactionItemTile(
                          orderId: '#BF-0259',
                          dateTime: '15 May · 11:06 · 1 Item · 2025',
                          amount: 18000,
                          status: 'Selesai',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Menu List
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.inputBorderColor,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      children: [
                        AccountMenuItem(
                          icon: Icons.person_outline_rounded,
                          title: 'Profil Akun',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.profile),
                        ),
                        const Divider(
                          height: 1,
                          color: AppColors.inputBorderColor,
                        ),
                        AccountMenuItem(
                          icon: Icons.logout_rounded,
                          title: 'Keluar akun',
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.login,
                              (r) => false,
                            );
                          },
                          iconColor: const Color(0xFFD32F2F),
                          titleColor: const Color(0xFFD32F2F),
                        ),
                        const Divider(
                          height: 1,
                          color: AppColors.inputBorderColor,
                        ),
                        AccountMenuItem(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifikasi',
                          onTap: () {},
                        ),
                        const Divider(
                          height: 1,
                          color: AppColors.inputBorderColor,
                        ),
                        AccountMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Pengaturan',
                          onTap: () {},
                        ),
                        const Divider(
                          height: 1,
                          color: AppColors.inputBorderColor,
                        ),
                        AccountMenuItem(
                          icon: Icons.help_outline_rounded,
                          title: 'Bantuan',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          bottomNavigationBar: HomeBottomNavBar(
            currentIndex: 3,
            orderBadgeCount: cartCount,
            onTap: (index) {
              if (index == 0) {
                Navigator.popUntil(context, (route) => route.isFirst);
              } else if (index == 1) {
                Navigator.pushNamed(context, AppRoutes.cart);
              }
            },
          ),
        );
      },
    );
  }
}
