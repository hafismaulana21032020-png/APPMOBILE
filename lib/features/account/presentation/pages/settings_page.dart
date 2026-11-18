import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../cart/domain/services/cart_service.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../../home/presentation/widgets/home_nav_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _orderStatusNotif = true;
  bool _promoNotif = false;
  bool _biometricLogin = true;

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.primaryBrown,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      'Pengaturan',
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

            // ================= SCROLLABLE CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),

                    // Subtitle
                    const Text(
                      'Atur BreakFree agar lebih pas untukmu.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.secondaryText,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── Section 1: Preferensi aplikasi ──
                    const _SectionHeader(title: 'Preferensi aplikasi'),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.inputBorderColor,
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          _NavigationTile(
                            icon: Icons.translate_rounded,
                            title: 'Bahasa',
                            trailingValue: 'Indonesia',
                            onTap: () => _showMessage('Bahasa saat ini: Indonesia'),
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.inputBorderColor,
                          ),
                          _NavigationTile(
                            icon: Icons.wb_sunny_outlined,
                            title: 'Tampilan',
                            trailingValue: 'Terang',
                            onTap: () => _showMessage('Mode tema: Terang'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── Section 2: Notifikasi ──
                    const _SectionHeader(title: 'Notifikasi'),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.inputBorderColor,
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          _SwitchTile(
                            icon: Icons.shopping_bag_outlined,
                            title: 'Status pesanan',
                            subtitle: 'Kabar saat kopimu siap diambil',
                            value: _orderStatusNotif,
                            onChanged: (val) {
                              setState(() => _orderStatusNotif = val);
                            },
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.inputBorderColor,
                          ),
                          _SwitchTile(
                            icon: Icons.discount_outlined,
                            title: 'Promo & penawaran',
                            subtitle: 'Promo spesial dan kabar terbaru',
                            value: _promoNotif,
                            onChanged: (val) {
                              setState(() => _promoNotif = val);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── Section 3: Keamanan & privasi ──
                    const _SectionHeader(title: 'Keamanan & privasi'),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.inputBorderColor,
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          _NavigationTile(
                            icon: Icons.lock_outline_rounded,
                            title: 'Ubah kata sandi',
                            onTap: () => _showMessage('Buka menu ubah kata sandi'),
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.inputBorderColor,
                          ),
                          _SwitchTile(
                            icon: Icons.fingerprint_rounded,
                            title: 'Masuk dengan biometrik',
                            subtitle: 'Akses lebih cepat dan aman',
                            value: _biometricLogin,
                            onChanged: (val) {
                              setState(() => _biometricLogin = val);
                            },
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.inputBorderColor,
                          ),
                          _NavigationTile(
                            icon: Icons.verified_user_outlined,
                            title: 'Kebijakan privasi',
                            onTap: () => _showMessage('Membuka kebijakan privasi BreakFree'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Section 4: Hapus Akun ──
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.inputBorderColor,
                          width: 1.0,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text(
                                'Hapus Akun?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD32F2F),
                                ),
                              ),
                              content: const Text(
                                'Tindakan ini permanen. Semua data akun, poin, dan riwayat pesanan akan dihapus dari BreakFree.',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _showMessage('Permintaan hapus akun diproses.');
                                  },
                                  child: const Text(
                                    'Hapus',
                                    style: TextStyle(color: Color(0xFFD32F2F)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 22,
                                color: Color(0xFFD32F2F),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'Hapus akun',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFD32F2F),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: Color(0xFFD32F2F),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Footer ──
                    Center(
                      child: Column(
                        children: const [
                          Text(
                            'BreakFree · Versi 1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Jeda sejenak, kopi dulu.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: CartService.instance,
        builder: (context, _) {
          return HomeBottomNavBar(
            currentIndex: 3,
            orderBadgeCount: CartService.instance.totalItemCount,
            onTap: (index) => handleSecondaryBottomNavTap(
              context,
              index,
              currentIndex: 3,
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingValue;
  final VoidCallback onTap;

  const _NavigationTile({
    required this.icon,
    required this.title,
    this.trailingValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 21, color: AppColors.secondaryText),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ),
              ),
            ),
            if (trailingValue != null) ...[
              Text(
                trailingValue!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(width: 4),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 21, color: AppColors.secondaryText),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.82,
            child: CupertinoSwitch(
              value: value,
              activeColor: AppColors.primaryBrown,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

