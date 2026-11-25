import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../cart/domain/services/cart_service.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../../home/presentation/widgets/home_nav_helper.dart';
import '../../domain/services/user_service.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _birthDateController;
  bool _isSaving = false;
  String? _verifiedCurrentPassword;

  @override
  void initState() {
    super.initState();
    final user = UserService.instance;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone ?? '');
    _birthDateController = TextEditingController(text: user.birthDate ?? '');
    _refreshFromBackend();
  }

  Future<void> _refreshFromBackend() async {
    final ok = await UserService.instance.syncWithBackend();
    if (ok && mounted) {
      final user = UserService.instance;
      setState(() {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone ?? '';
        _birthDateController.text = user.birthDate ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _onSelectBirthDate() async {
    final now = DateTime.now();
    final initialDate = DateTime(2000, 1, 1);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBrown,
              onPrimary: Colors.white,
              onSurface: AppColors.darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;
    if (pickedDate != null) {
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final formatted =
          '${pickedDate.day} ${months[pickedDate.month - 1]} ${pickedDate.year}';
      setState(() {
        _birthDateController.text = formatted;
      });
    }
  }

  Future<void> _showQuickAddPhoneDialog() async {
    final savedPhone = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => _QuickPhoneDialog(
        initialPhone: _phoneController.text.trim(),
      ),
    );

    if (savedPhone != null) {
      _phoneController.text = savedPhone;
      await _onSaveProfile();
    }
  }

  Future<String?> _showPasswordVerificationDialog() async {
    final navigator = Navigator.of(context);
    final email = UserService.instance.email.trim();
    final verifiedPassword = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => _PasswordVerificationDialog(
        onForgotPassword: () {
          Navigator.pop(dialogCtx);
          navigator.pushNamed(
            AppRoutes.forgotPassword,
            arguments: email.isNotEmpty ? email : null,
          );
        },
      ),
    );

    if (verifiedPassword != null && mounted) {
      setState(() => _verifiedCurrentPassword = verifiedPassword);
    }
    return verifiedPassword;
  }

  Future<void> _onSaveProfile() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final birthDate = _birthDateController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan Email tidak boleh kosong'),
          backgroundColor: Color(0xFFC93B2B),
        ),
      );
      return;
    }

    if (!AppValidators.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid'),
          backgroundColor: Color(0xFFC93B2B),
        ),
      );
      return;
    }

    if (phone.isNotEmpty && !RegExp(r'^[0-9+\-\s]{8,20}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format nomor telepon tidak valid (minimal 8 digit angka)'),
          backgroundColor: Color(0xFFC93B2B),
        ),
      );
      return;
    }

    String? currentPass = _verifiedCurrentPassword;
    if (UserService.instance.hasPassword && currentPass == null) {
      currentPass = await _showPasswordVerificationDialog();
      if (!mounted || currentPass == null) return;
    }

    setState(() => _isSaving = true);
    try {
      final res = await UserService.instance.updateProfileAsync(
        name: name,
        phone: phone,
        birthDate: birthDate,
        currentPassword: currentPass,
      );
      if (!mounted) return;
      final ok = res['success'] == true;
      if (!ok && res['requiresPasswordVerification'] == true) {
        setState(() => _verifiedCurrentPassword = null);
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res['message']?.toString() ??
                (ok ? 'Perubahan profil berhasil disimpan!' : 'Gagal menyimpan profil.'),
          ),
          backgroundColor: ok ? const Color(0xFF2E7D32) : const Color(0xFFC93B2B),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    String? hintText,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: readOnly ? const Color(0xFFFAF7F2) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.inputBorderColor,
              width: 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.hintColor,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              prefixIcon: Icon(
                prefixIcon,
                size: 20,
                color: AppColors.secondaryText,
              ),
              suffixIcon: suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: suffixIcon,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([UserService.instance, CartService.instance]),
      builder: (context, _) {
        final user = UserService.instance;
        final cartCount = CartService.instance.totalItemCount;
        final hasPhone = user.phone != null && user.phone!.isNotEmpty;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.lg,
                vertical: AppDimensions.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                          'Profil Akun',
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
                  const SizedBox(height: 18),

                  // Top Profile Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.inputBorderColor,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1EAE4),
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          alignment: Alignment.center,
                          child: user.avatarUrl != null
                              ? Image.network(
                                  user.avatarUrl!,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Text(
                                    user.initials,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF5D4037),
                                    ),
                                  ),
                                )
                              : Text(
                                  user.initials,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5D4037),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name.isNotEmpty ? user.name : 'Pengguna BreakFree',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7EFE6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user.memberBadge,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8D6E63),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Informasi pribadi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Pastikan datamu selalu terbaru.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    label: 'Nama lengkap',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline_rounded,
                    hintText: 'Masukkan nama lengkap',
                    suffixIcon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildFormField(
                    label: 'Email',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    readOnly: true,
                    suffixIcon: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: Color(0xFF0F9D58),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Status Nomor Telepon + Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Nomor telepon',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                      if (!hasPhone) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _showQuickAddPhoneDialog,
                          child: const Text(
                            '+ Tambahkan nomor',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBrown,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.inputBorderColor,
                        width: 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkText,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Belum ditambahkan',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondaryText,
                          fontStyle: FontStyle.italic,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          size: 20,
                          color: AppColors.secondaryText,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: AppColors.secondaryText,
                          ),
                          onPressed: _showQuickAddPhoneDialog,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildFormField(
                    label: 'Tanggal lahir',
                    controller: _birthDateController,
                    prefixIcon: Icons.calendar_today_outlined,
                    hintText: 'Belum diatur',
                    readOnly: true,
                    onTap: _onSelectBirthDate,
                    suffixIcon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: (!user.hasPassword || _verifiedCurrentPassword != null)
                          ? const Color(0xFFE8F8F0)
                          : AppColors.cardBgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (!user.hasPassword || _verifiedCurrentPassword != null)
                            ? const Color(0xFFC8E6C9)
                            : AppColors.inputBorderColor,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              (!user.hasPassword || _verifiedCurrentPassword != null)
                                  ? Icons.verified_user_outlined
                                  : Icons.lock_outline_rounded,
                              size: 18,
                              color: (!user.hasPassword || _verifiedCurrentPassword != null)
                                  ? const Color(0xFF0F9D58)
                                  : AppColors.primaryBrown,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                !user.hasPassword
                                    ? 'Email terverifikasi. Data pribadimu tersimpan aman di database BreakFree.'
                                    : (_verifiedCurrentPassword != null
                                        ? 'Akun terverifikasi. Perubahan profil siap disimpan.'
                                        : 'Perlu verifikasi kata sandi saat menyimpan perubahan profil.'),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: (!user.hasPassword || _verifiedCurrentPassword != null)
                                      ? const Color(0xFF2E6A4F)
                                      : AppColors.darkText,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (user.hasPassword && _verifiedCurrentPassword == null) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 14,
                            runSpacing: 6,
                            children: [
                              GestureDetector(
                                onTap: _isSaving ? null : _showPasswordVerificationDialog,
                                child: const Text(
                                  'Verifikasi Sekarang',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBrown,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _isSaving
                                    ? null
                                    : () => Navigator.pushNamed(
                                          context,
                                          AppRoutes.forgotPassword,
                                          arguments: user.email.trim().isNotEmpty
                                              ? user.email.trim()
                                              : null,
                                        ),
                                child: const Text(
                                  'Lupa kata sandi? Reset dengan Gmail',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondaryText,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: () => showVerifiedChangePasswordSheet(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.inputBorderColor,
                          width: 1.0,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.password_rounded,
                            size: 19,
                            color: AppColors.primaryBrown,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Ubah kata sandi akun',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: AppColors.secondaryText,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _onSaveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrown,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan perubahan',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
              popOnCurrent: true,
            ),
          ),
        );
      },
    );
  }
}

class _QuickPhoneDialog extends StatefulWidget {
  final String initialPhone;

  const _QuickPhoneDialog({required this.initialPhone});

  @override
  State<_QuickPhoneDialog> createState() => _QuickPhoneDialogState();
}

class _QuickPhoneDialogState extends State<_QuickPhoneDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        'Nomor Telepon',
        style: TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      ),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.phone,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Contoh: 081234567890',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: AppColors.secondaryText)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBrown,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Simpan', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _PasswordVerificationDialog extends StatefulWidget {
  final VoidCallback onForgotPassword;

  const _PasswordVerificationDialog({required this.onForgotPassword});

  @override
  State<_PasswordVerificationDialog> createState() =>
      _PasswordVerificationDialogState();
}

class _PasswordVerificationDialogState
    extends State<_PasswordVerificationDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isVerifying = false;
  String? _errorMsg;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final pwd = _passwordController.text.trim();
    if (pwd.isEmpty) {
      setState(
        () => _errorMsg = 'Masukkan kata sandi saat ini terlebih dahulu.',
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMsg = null;
    });

    try {
      final res = await ApiService.instance.verifyCurrentPassword(pwd);
      if (!mounted) return;
      if (res['success'] == true && res['verified'] == true) {
        Navigator.pop(context, pwd);
      } else {
        setState(() {
          _isVerifying = false;
          _errorMsg =
              res['message']?.toString() ?? 'Kata sandi saat ini tidak sesuai.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _errorMsg = 'Gagal memverifikasi kata sandi: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      title: const Text(
        'Verifikasi Akun Dulu',
        style: TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan kata sandi kamu yang sekarang untuk melanjutkan perubahan profil akun.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.secondaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Kata Sandi Saat Ini',
                hintText: 'Masukkan kata sandi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 19,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
            ),
            if (_errorMsg != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMsg!,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _isVerifying ? null : widget.onForgotPassword,
                child: const Text(
                  'Lupa kata sandi? Reset dengan Gmail',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBrown,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : () => Navigator.pop(context),
          child: const Text(
            'Batal',
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
        ElevatedButton(
          onPressed: _isVerifying ? null : _handleVerify,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBrown,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: _isVerifying
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Verifikasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}
