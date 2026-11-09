import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../widgets/account_banner_card.dart';
import '../widgets/account_menu_item.dart';
import '../widgets/account_profile_card.dart';
import '../widgets/account_quick_actions.dart';
import '../widgets/account_stats_row.dart';
import '../widgets/transaction_item_tile.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final int _currentNavIndex = 3;

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } else if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.cart);
    }
    // index 2 = Asisten AI, index 3 = Akun (current)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============ HEADER BAR ============
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.inputBorderColor,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 20,
                      color: AppColors.darkBrown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ============ BANNER CARD ============
              const AccountBannerCard(userName: 'HAFIZZ'),
              const SizedBox(height: 14),

              // ============ PROFILE CARD ============
              const AccountProfileCard(
                initials: 'HM',
                name: 'HAFIZ MAULANA',
                email: 'hafiz.maulana@gmail.com',
                memberBadge: 'Member Gold',
              ),
              const SizedBox(height: 10),

              // ============ STATS ROW ============
              const AccountStatsRow(poin: 1240, pesanan: 12, promo: 3),
              const SizedBox(height: 10),

              // ============ QUICK ACTIONS ============
              AccountQuickActions(
                onOrderTap: () => Navigator.pushNamed(context, AppRoutes.cart),
              ),
              const SizedBox(height: 14),

              // ============ LACAK PESANAN BUTTON ============
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
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Lacak Pesanan',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ============ TRANSAKSI TERBARU ============
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transaksi terbaru',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
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
              const SizedBox(height: 4),

              // Transaction list
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.inputBorderColor, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    const TransactionItemTile(
                      orderId: '#BF-0302',
                      dateTime: '28 Jun · 19:41 · 3 Item · 2025',
                      amount: 45000,
                      status: 'Selesai',
                    ),
                    const Divider(height: 1, color: AppColors.inputBorderColor),
                    const TransactionItemTile(
                      orderId: '#BF-0297',
                      dateTime: '21 Jun · 12:36 · 1 Item · 16 May',
                      amount: 62000,
                      status: 'Selesai',
                    ),
                    const Divider(height: 1, color: AppColors.inputBorderColor),
                    const TransactionItemTile(
                      orderId: '#BF-0259',
                      dateTime: '15 May · 11:06 · 1 Item · 2025',
                      amount: 18000,
                      status: 'Selesai',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ============ MENU LIST ============
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.inputBorderColor, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    AccountMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Profil Akun',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: AppColors.inputBorderColor),
                    AccountMenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Keluar akun',
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                      iconColor: const Color(0xFFD32F2F),
                      titleColor: const Color(0xFFD32F2F),
                    ),
                    const Divider(height: 1, color: AppColors.inputBorderColor),
                    AccountMenuItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifikasi',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: AppColors.inputBorderColor),
                    AccountMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Pengaturan',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: AppColors.inputBorderColor),
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
        currentIndex: _currentNavIndex,
        orderBadgeCount: 2,
        onTap: _onNavTap,
      ),
    );
  }
}

