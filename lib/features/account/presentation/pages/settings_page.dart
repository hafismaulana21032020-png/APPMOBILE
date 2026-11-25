import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/password_similarity_warning_dialog.dart';
import '../../domain/services/user_service.dart';
import '../../../cart/domain/services/cart_service.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../../home/presentation/widgets/home_nav_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'Indonesia';
  String _selectedTheme = 'Terang';
  bool _orderStatusNotif = true;
  bool _promoNotif = false;
  bool _biometricLogin = true;

  @override
  void initState() {
    super.initState();
    UserService.instance.syncWithBackend();
  }

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

  // ══════════════════════ 1. BAHASA MODAL SHEET ══════════════════════
  void _showLanguageSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.inputBorderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Bahasa / Language',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pilih bahasa yang nyaman untuk antarmuka BreakFree.',
                style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 16),
              _buildSelectionTile(
                title: 'Bahasa Indonesia',
                subtitle: 'Gunakan Bahasa Indonesia',
                isSelected: _selectedLanguage == 'Indonesia',
                onTap: () {
                  setState(() => _selectedLanguage = 'Indonesia');
                  Navigator.pop(sheetCtx);
                  _showMessage('Bahasa berhasil diubah ke Bahasa Indonesia');
                },
              ),
              const SizedBox(height: 8),
              _buildSelectionTile(
                title: 'English',
                subtitle: 'Use English language',
                isSelected: _selectedLanguage == 'English',
                onTap: () {
                  setState(() => _selectedLanguage = 'English');
                  Navigator.pop(sheetCtx);
                  _showMessage('Language changed to English');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════ 2. TEMA TAMPILAN MODAL SHEET ══════════════════════
  void _showThemeSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.inputBorderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Tema Tampilan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Atur kenyamanan visual sesuai selera matamu.',
                style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 16),
              _buildSelectionTile(
                icon: Icons.wb_sunny_rounded,
                title: 'Terang (Light)',
                subtitle: 'Nuansa hangat khas kopi BreakFree',
                isSelected: _selectedTheme == 'Terang',
                onTap: () {
                  setState(() => _selectedTheme = 'Terang');
                  Navigator.pop(sheetCtx);
                  _showMessage('Tema tampilan diatur ke Terang');
                },
              ),
              const SizedBox(height: 8),
              _buildSelectionTile(
                icon: Icons.nightlight_round,
                title: 'Gelap (Dark)',
                subtitle: 'Nyaman di mata saat suasana redup',
                isSelected: _selectedTheme == 'Gelap',
                onTap: () {
                  setState(() => _selectedTheme = 'Gelap');
                  Navigator.pop(sheetCtx);
                  _showMessage('Tema tampilan diatur ke Gelap');
                },
              ),
              const SizedBox(height: 8),
              _buildSelectionTile(
                icon: Icons.brightness_auto_rounded,
                title: 'Ikuti Sistem',
                subtitle: 'Menyesuaikan mode perangkat secara otomatis',
                isSelected: _selectedTheme == 'Ikuti Sistem',
                onTap: () {
                  setState(() => _selectedTheme = 'Ikuti Sistem');
                  Navigator.pop(sheetCtx);
                  _showMessage('Tema tampilan mengikuti sistem perangkat');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════ 3. UBAH KATA SANDI MODAL SHEET ══════════════════════
  void _showChangePasswordSheet() {
    showVerifiedChangePasswordSheet(context);
  }

  // ══════════════════════ 4. KEBIJAKAN PRIVASI MODAL SHEET ══════════════════════
  void _showPrivacyPolicySheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        height: MediaQuery.of(sheetCtx).size.height * 0.82,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.inputBorderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kebijakan Privasi',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(sheetCtx),
                  ),
                ],
              ),
              const Divider(height: 1, color: AppColors.inputBorderColor),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Pembaruan Terakhir: 19 November 2026',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      SizedBox(height: 14),
                      _PolicySection(
                        number: '1',
                        title: 'Pengumpulan Informasi',
                        content:
                            'BreakFree mengumpulkan data seperti nama, email, nomor telepon, dan riwayat pesanan saat kamu membuat akun atau melakukan transaksi untuk memastikan pemesanan berjalan lancar.',
                      ),
                      _PolicySection(
                        number: '2',
                        title: 'Penggunaan Data',
                        content:
                            'Informasi digunakan untuk memproses pesanan kopi dan makanan, memperbarui status pesanan live tracking, memberikan cashback poin, serta menghadirkan penawaran voucher yang relevan.',
                      ),
                      _PolicySection(
                        number: '3',
                        title: 'Keamanan Data Pembayaran',
                        content:
                            'Seluruh transaksi pembayaran digital (QRIS, E-Wallet) dilindungi enkripsi standar industri. BreakFree tidak menyimpan nomor PIN maupun kata sandi rekening bank pribadimu.',
                      ),
                      _PolicySection(
                        number: '4',
                        title: 'Hak Pengguna & Privasi',
                        content:
                            'Kamu berhak menonaktifkan notifikasi promo, mengubah kata sandi, maupun mengajukan penghapusan akun beserta riwayat datanya kapan saja melalui halaman Pengaturan.',
                      ),
                      _PolicySection(
                        number: '5',
                        title: 'Kontak Layanan Pelanggan',
                        content:
                            'Jika memiliki pertanyaan seputar kebijakan privasi, kamu dapat menghubungi kami melalui bantuan@breakfree.id atau via fitur Chat Barista AI.',
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetCtx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Saya Mengerti',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════ 5. HAPUS AKUN DIALOG ══════════════════════
  void _showDeleteAccountDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Hapus Akun Permanen?',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Tindakan ini tidak dapat dibatalkan. Seluruh data profil akun, poin cashback, serta riwayat pesanan akan dihapus permanen dari BreakFree.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.darkText,
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
              _showMessage('Akun BreakFree berhasil dihapus.');
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
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
              'Hapus Akun',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionTile({
    IconData? icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.backgroundColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBrown
                : AppColors.inputBorderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.primaryBrown
                    : AppColors.secondaryText,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? AppColors.darkBrown
                          : AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryBrown,
                size: 20,
              ),
          ],
        ),
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
                            trailingValue: _selectedLanguage,
                            onTap: _showLanguageSheet,
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.inputBorderColor,
                          ),
                          _NavigationTile(
                            icon: Icons.wb_sunny_outlined,
                            title: 'Tampilan',
                            trailingValue: _selectedTheme,
                            onTap: _showThemeSheet,
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
                              _showMessage(
                                val
                                    ? 'Notifikasi status pesanan diaktifkan'
                                    : 'Notifikasi status pesanan dinonaktifkan',
                              );
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
                              _showMessage(
                                val
                                    ? 'Notifikasi promo & penawaran diaktifkan'
                                    : 'Notifikasi promo & penawaran dinonaktifkan',
                              );
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
                            onTap: _showChangePasswordSheet,
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
                              _showMessage(
                                val
                                    ? 'Login biometrik diaktifkan'
                                    : 'Login biometrik dinonaktifkan',
                              );
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
                            onTap: _showPrivacyPolicySheet,
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
                        onTap: _showDeleteAccountDialog,
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
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
                    const Center(
                      child: Column(
                        children: [
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
      borderRadius: BorderRadius.circular(16),
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
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
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
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String number;
  final String title;
  final String content;

  const _PolicySection({
    required this.number,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.cardBgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBrown,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.secondaryText,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showVerifiedChangePasswordSheet(
  BuildContext context, {
  @visibleForTesting bool skipVerificationForTest = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => _ChangePasswordSheetContent(
      skipVerificationForTest: skipVerificationForTest,
    ),
  );
}

enum _ChangePasswordStep {
  verifyCurrent,
  createNew,
}

class _ChangePasswordSheetContent extends StatefulWidget {
  final bool skipVerificationForTest;

  const _ChangePasswordSheetContent({
    this.skipVerificationForTest = false,
  });

  @override
  State<_ChangePasswordSheetContent> createState() =>
      _ChangePasswordSheetContentState();
}

class _ChangePasswordSheetContentState
    extends State<_ChangePasswordSheetContent> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  late _ChangePasswordStep _step;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _similarityWarning;

  @override
  void initState() {
    super.initState();
    _step = widget.skipVerificationForTest
        ? _ChangePasswordStep.createNew
        : _ChangePasswordStep.verifyCurrent;
    _newController.addListener(_evaluateLiveSimilarity);
  }

  void _evaluateLiveSimilarity() {
    if (!UserService.instance.hasPassword) return;
    final oldPass = _oldController.text.trim();
    final newPass = _newController.text.trim();
    if (oldPass.isEmpty || newPass.isEmpty) {
      if (_similarityWarning != null && mounted) {
        setState(() => _similarityWarning = null);
      }
      return;
    }

    final similarity =
        AppValidators.evaluatePasswordSimilarity(oldPass, newPass);
    String? nextWarning;
    if (similarity == PasswordSimilarity.identical) {
      nextWarning =
          'Kata sandi baru sama persis dengan kata sandi sebelumnya. Silakan gunakan kata sandi lain.';
    } else if (similarity == PasswordSimilarity.similar) {
      nextWarning =
          'Peringatan: Kata sandi baru hampir sama dengan kata sandi sebelumnya. Disarankan gunakan kombinasi yang lebih berbeda.';
    }

    if (nextWarning != _similarityWarning && mounted) {
      setState(() => _similarityWarning = nextWarning);
    }
  }

  @override
  void dispose() {
    _newController.removeListener(_evaluateLiveSimilarity);
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _openForgotPasswordViaGmail() {
    final email = UserService.instance.email.trim();
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushNamed(
      AppRoutes.forgotPassword,
      arguments: email.isNotEmpty ? email : null,
    );
  }

  Future<void> _verifyCurrentPassword() async {
    final oldPass = _oldController.text.trim();
    setState(() => _errorMessage = null);

    if (oldPass.isEmpty) {
      setState(() => _errorMessage = 'Kata sandi lama harus diisi.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final res = await ApiService.instance.verifyCurrentPassword(oldPass);
      if (!mounted) return;

      if (res['success'] == true && res['verified'] == true) {
        setState(() {
          _step = _ChangePasswordStep.createNew;
          _errorMessage = null;
          _similarityWarning = null;
        });
      } else {
        setState(() {
          _errorMessage =
              res['message']?.toString() ?? 'Kata sandi lama tidak sesuai.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Gagal terhubung ke server: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _submitNewPassword({bool allowSimilar = false}) async {
    final oldPass = _oldController.text.trim();
    final newPass = _newController.text.trim();
    final confirmPass = _confirmController.text.trim();
    final hasExistingPassword = UserService.instance.hasPassword;

    setState(() => _errorMessage = null);

    if (newPass.length < 6) {
      setState(() => _errorMessage = 'Kata sandi baru minimal 6 karakter.');
      return;
    }
    if (newPass != confirmPass) {
      setState(() => _errorMessage = 'Konfirmasi kata sandi tidak cocok.');
      return;
    }

    if (hasExistingPassword) {
      final localSimilarity =
          AppValidators.evaluatePasswordSimilarity(oldPass, newPass);
      if (localSimilarity == PasswordSimilarity.identical) {
        setState(
          () => _errorMessage =
              'Kata sandi baru harus berbeda dari kata sandi lama.',
        );
        return;
      }
      if (localSimilarity == PasswordSimilarity.similar && !allowSimilar) {
        final proceed = await showPasswordSimilarityWarningDialog(context);
        if (!mounted || !proceed) return;
        allowSimilar = true;
      }
    }

    setState(() => _isSubmitting = true);
    try {
      final res = await ApiService.instance.changePassword(
        currentPassword: hasExistingPassword ? oldPass : null,
        newPassword: newPass,
        allowSimilar: allowSimilar,
      );
      if (!mounted) return;

      if (res['success'] == true) {
        await UserService.instance.syncWithBackend();
        if (!mounted) return;
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        navigator.pop();
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              res['message']?.toString() ?? 'Kata sandi berhasil diperbarui!',
            ),
            backgroundColor: AppColors.primaryBrown,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (res['code'] == 'PASSWORD_TOO_SIMILAR' && !allowSimilar) {
        setState(() => _isSubmitting = false);
        final proceed = await showPasswordSimilarityWarningDialog(
          context,
          customMessage: res['message']?.toString(),
        );
        if (proceed && mounted) {
          await _submitNewPassword(allowSimilar: true);
        }
        return;
      } else {
        setState(() {
          _errorMessage =
              res['message']?.toString() ?? 'Gagal memperbarui kata sandi.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal terhubung ke server: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final hasExistingPassword = UserService.instance.hasPassword;
    final userEmail = UserService.instance.email.trim();

    final titleText = _step == _ChangePasswordStep.verifyCurrent
        ? (hasExistingPassword
            ? 'Verifikasi Kata Sandi Lama'
            : 'Verifikasi via OTP Gmail')
        : 'Ubah Kata Sandi';

    final subtitleText = _step == _ChangePasswordStep.verifyCurrent
        ? (hasExistingPassword
            ? 'Masukkan kata sandi lama kamu terlebih dahulu untuk verifikasi sebelum membuat kata sandi baru.'
            : 'Akun ini masuk dengan Google dan belum memiliki kata sandi. Verifikasi email dengan kode OTP untuk mengatur kata sandi.')
        : 'Buat kata sandi baru yang kuat dan berbeda dari kata sandi sebelumnya.';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + viewInsets),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.inputBorderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                titleText,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitleText,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFCDD2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFD32F2F),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFFD32F2F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              if (_step == _ChangePasswordStep.verifyCurrent) ...[
                if (hasExistingPassword) ...[
                  _buildPasswordField(
                    label: 'Kata Sandi Lama',
                    controller: _oldController,
                    obscure: _obscureOld,
                    onToggleObscure: () =>
                        setState(() => _obscureOld = !_obscureOld),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _isSubmitting ? null : _openForgotPasswordViaGmail,
                      child: const Text(
                        'Lupa kata sandi? Reset dengan Gmail (OTP)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBrown,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _verifyCurrentPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Verifikasi Kata Sandi Lama',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.inputBorderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: AppColors.inputBorderColor,
                            ),
                          ),
                          child: const Icon(
                            Icons.mail_outline_rounded,
                            size: 18,
                            color: AppColors.primaryBrown,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email tujuan OTP',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userEmail.isNotEmpty
                                    ? userEmail
                                    : 'Gmail akun terdaftar',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          _isSubmitting ? null : _openForgotPasswordViaGmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Kirim & Verifikasi OTP via Gmail',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ] else ...[
                if (hasExistingPassword) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFA5D6A7)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: Color(0xFF2E7D32),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kata sandi lama terverifikasi',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _buildPasswordField(
                  label: 'Kata Sandi Baru (min. 6 karakter)',
                  controller: _newController,
                  obscure: _obscureNew,
                  onToggleObscure: () =>
                      setState(() => _obscureNew = !_obscureNew),
                ),
                if (_similarityWarning != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFCA28)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: Color(0xFFEF6C00),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _similarityWarning!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF8D4E00),
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _buildPasswordField(
                  label: 'Ulangi Kata Sandi Baru',
                  controller: _confirmController,
                  obscure: _obscureConfirm,
                  onToggleObscure: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submitNewPassword(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBrown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Simpan Kata Sandi Baru',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontSize: 13.5, color: AppColors.darkText),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle:
              const TextStyle(fontSize: 12, color: AppColors.secondaryText),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: AppColors.secondaryText,
            ),
            onPressed: onToggleObscure,
          ),
        ),
      ),
    );
  }
}
