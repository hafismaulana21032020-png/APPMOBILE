import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/google_auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/auth_header_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../account/domain/services/notification_service.dart';
import '../../../account/domain/services/user_service.dart';
import '../../../home/domain/services/favorite_service.dart';
import '../../../home/domain/services/menu_service.dart';
import '../../../home/domain/services/promo_service.dart';
import '../../../order/domain/services/order_service.dart';
import '../widgets/auth_info_card.dart';
import '../widgets/google_sign_in_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;
  bool _isAgreed = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  StreamSubscription<Map<String, dynamic>>? _webGoogleSub;

  @override
  void initState() {
    super.initState();
    _webGoogleSub = GoogleAuthService.instance.webSignInResults.listen((res) async {
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      if (res['success'] == true) {
        setState(() => _isGoogleLoading = true);
        try {
          await _completeAuth(res);
        } finally {
          if (mounted) setState(() => _isGoogleLoading = false);
        }
      } else if (res['cancelled'] != true) {
        _showMessage(
          res['message']?.toString() ?? 'Gagal daftar dengan Google.',
          isError: true,
        );
      }
    });
  }

  @override
  void dispose() {
    _webGoogleSub?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFC93B2B) : AppColors.primaryBrown,
      ),
    );
  }

  Future<void> _completeAuth(Map<String, dynamic> res) async {
    if (res['token'] != null) {
      await ApiService.instance.setAuthToken(res['token'].toString());
    }
    if (res['customer'] is Map<String, dynamic>) {
      UserService.instance.setFromJson(res['customer'] as Map<String, dynamic>);
    } else {
      await UserService.instance.syncWithBackend();
    }

    await Future.wait([
      MenuService.instance.fetchMenu(force: true),
      FavoriteService.instance.fetchFavorites(),
      PromoService.instance.fetchActivePromos(force: true),
      OrderService.instance.syncActiveOrderFromBackend(),
      OrderService.instance.loadHistoryFromBackend(),
      NotificationService.instance.fetchNotifications(),
    ]);

    if (!mounted) return;
    _showMessage(
      res['message']?.toString() ?? 'Akun berhasil dibuat! Selamat datang, ${UserService.instance.name}',
    );
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  Future<void> _onRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Silakan lengkapi nama, email, dan kata sandi terlebih dahulu', isError: true);
      return;
    }

    if (!AppValidators.isValidEmail(email)) {
      _showMessage('Format email tidak valid', isError: true);
      return;
    }

    if (phone.isNotEmpty && !RegExp(r'^[0-9+\-\s]{8,20}$').hasMatch(phone)) {
      _showMessage('Format nomor telepon tidak valid (minimal 8 digit angka)', isError: true);
      return;
    }

    if (!AppValidators.isStrongPassword(password)) {
      _showMessage('Kata sandi minimal 8 karakter dan mengandung huruf serta angka', isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Konfirmasi kata sandi tidak cocok', isError: true);
      return;
    }

    if (!_isAgreed) {
      _showMessage('Silakan setujui Syarat dan Ketentuan terlebih dahulu', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.instance.register(
        name: name,
        email: email,
        password: password,
        phone: phone.isEmpty ? null : phone,
      );

      if (res['success'] == true) {
        await _completeAuth(res);
      } else {
        _showMessage(
          res['message']?.toString() ?? 'Gagal mendaftarkan akun.',
          isError: true,
        );
      }
    } catch (e) {
      _showMessage('Gagal terhubung ke server: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onGoogleSignUp() async {
    setState(() => _isGoogleLoading = true);
    try {
      final res = await GoogleAuthService.instance.signInWithGoogle();
      if (res['success'] == true) {
        await _completeAuth(res);
      } else if (res['cancelled'] != true) {
        _showMessage(
          res['message']?.toString() ?? 'Gagal daftar dengan Google.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.xxl,
            vertical: AppDimensions.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeaderBar(onBackPressed: () => Navigator.pop(context)),
              const SizedBox(height: AppDimensions.xxl),

              const Text(
                'Yuk, jadi bagian BreakFree!',
                style: AppTextStyles.headingLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'Buat akun untuk pengalaman ngopi yang lebih mudah dan penuh keuntungan.',
                style: AppTextStyles.bodyDescription,
              ),
              const SizedBox(height: AppDimensions.xl),

              const AuthInfoCard(
                icon: Icons.auto_awesome,
                title: 'Ngopi, kumpulkan poin, nikmati promo.',
                subtitle: 'Semua keuntungan dalam satu akun.',
              ),
              const SizedBox(height: AppDimensions.xl),

              GoogleSignInButton(
                text: 'Daftar dengan Google',
                isLoading: _isGoogleLoading,
                isSignUp: true,
                onPressed: _isLoading ? null : _onGoogleSignUp,
              ),
              const SizedBox(height: AppDimensions.lg),

              Row(
                children: const [
                  Expanded(child: Divider(color: AppColors.inputBorderColor)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'atau daftar manual',
                      style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.inputBorderColor)),
                ],
              ),
              const SizedBox(height: AppDimensions.lg),

              CustomTextField(
                label: 'Nama lengkap',
                controller: _nameController,
                hintText: 'Masukkan nama lengkap kamu',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: AppDimensions.lg),

              CustomTextField(
                label: 'Email',
                controller: _emailController,
                hintText: 'Masukkan email kamu',
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppDimensions.lg),

              CustomTextField(
                label: 'Nomor telepon (Opsional)',
                controller: _phoneController,
                hintText: 'Contoh: 081234567890 (boleh kosong)',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppDimensions.lg),

              CustomTextField(
                label: 'Kata sandi',
                controller: _passwordController,
                hintText: 'Buat kata sandi',
                prefixIcon: Icons.lock_outline,
                isObscure: _isObscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.secondaryText,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscurePassword = !_isObscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Minimal 8 karakter, gunakan huruf dan angka.',
                style: AppTextStyles.helperText,
              ),
              const SizedBox(height: AppDimensions.lg),

              CustomTextField(
                label: 'Konfirmasi kata sandi',
                controller: _confirmPasswordController,
                hintText: 'Ulangi kata sandi',
                prefixIcon: Icons.lock_outline,
                isObscure: _isObscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.secondaryText,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscureConfirmPassword = !_isObscureConfirmPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _isAgreed,
                      activeColor: AppColors.primaryBrown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm / 2),
                      ),
                      side: const BorderSide(color: AppColors.inputBorderColor, width: 1.5),
                      onChanged: (bool? value) {
                        setState(() {
                          _isAgreed = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                          height: 1.3,
                        ),
                        children: [
                          TextSpan(text: 'Saya menyetujui '),
                          TextSpan(
                            text: 'Syarat dan Ketentuan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          TextSpan(text: ' serta '),
                          TextSpan(
                            text: 'Kebijakan Privasi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          TextSpan(text: ' BreakFree.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.xxl),

              CustomButton(
                text: 'Daftar',
                isLoading: _isLoading,
                onPressed: _isGoogleLoading ? null : _onRegister,
              ),
              const SizedBox(height: AppDimensions.xl),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                      ),
                      children: [
                        TextSpan(text: 'Sudah punya akun? '),
                        TextSpan(
                          text: 'Masuk',
                          style: AppTextStyles.linkTextBold,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
