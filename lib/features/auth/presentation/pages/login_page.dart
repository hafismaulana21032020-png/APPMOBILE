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
import '../widgets/coffee_banner.dart';
import '../widgets/google_sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  StreamSubscription<Map<String, dynamic>>? _webGoogleSub;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
    _webGoogleSub = GoogleAuthService.instance.webSignInResults.listen((res) async {
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      if (res['success'] == true) {
        setState(() => _isGoogleLoading = true);
        try {
          await _completeSignIn(res);
        } finally {
          if (mounted) setState(() => _isGoogleLoading = false);
        }
      } else if (res['cancelled'] != true) {
        _showSnackBar(
          res['message']?.toString() ?? 'Gagal masuk dengan Google.',
          isError: true,
        );
      }
    });
  }

  Future<void> _checkExistingSession() async {
    await ApiService.instance.loadSavedToken();
    if (!ApiService.instance.hasToken) return;

    final synced = await UserService.instance.syncWithBackend();
    if (synced && mounted) {
      await _hydrateAppServices();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  Future<void> _hydrateAppServices() async {
    await Future.wait([
      MenuService.instance.fetchMenu(force: true),
      FavoriteService.instance.fetchFavorites(),
      PromoService.instance.fetchActivePromos(force: true),
      OrderService.instance.syncActiveOrderFromBackend(),
      OrderService.instance.loadHistoryFromBackend(),
      NotificationService.instance.fetchNotifications(),
    ]);
  }

  @override
  void dispose() {
    _webGoogleSub?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFC93B2B) : AppColors.primaryBrown,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _completeSignIn(Map<String, dynamic> res) async {
    if (res['token'] != null) {
      await ApiService.instance.setAuthToken(res['token'].toString());
    }
    if (res['customer'] is Map<String, dynamic>) {
      UserService.instance.setFromJson(res['customer'] as Map<String, dynamic>);
    } else {
      await UserService.instance.syncWithBackend();
    }
    await _hydrateAppServices();

    if (!mounted) return;
    final name = UserService.instance.name.isNotEmpty
        ? UserService.instance.name
        : UserService.instance.email;
    _showSnackBar('Berhasil masuk! Selamat datang, $name');
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Silakan masukkan email dan kata sandi terlebih dahulu', isError: true);
      return;
    }

    if (!AppValidators.isValidEmail(email)) {
      _showSnackBar('Format email tidak valid', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.instance.login(email: email, password: password);
      if (res['success'] == true) {
        await _completeSignIn(res);
      } else {
        _showSnackBar(
          res['message']?.toString() ?? 'Email atau kata sandi salah.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Gagal terhubung ke server: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final res = await GoogleAuthService.instance.signInWithGoogle();
      if (res['success'] == true) {
        await _completeSignIn(res);
      } else if (res['cancelled'] != true) {
        _showSnackBar(
          res['message']?.toString() ?? 'Gagal masuk dengan Google.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _navigateToRegister() {
    Navigator.pushNamed(context, AppRoutes.register);
  }

  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.xxl,
            vertical: AppDimensions.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthHeaderBar(showBackButton: false),
              const SizedBox(height: AppDimensions.md),
              const CoffeeBanner(),
              const SizedBox(height: AppDimensions.xl),

              const Text(
                'Selamat datang kembali!',
                style: AppTextStyles.headingLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'Masuk untuk pesan kopi favorit dan nikmati promo khusus untukmu.',
                style: AppTextStyles.bodyDescription,
              ),
              const SizedBox(height: AppDimensions.xl),

              CustomTextField(
                label: 'Email',
                controller: _emailController,
                hintText: 'nama@email.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppDimensions.lg),

              CustomTextField(
                label: 'Kata sandi',
                controller: _passwordController,
                hintText: 'Masukkan kata sandi',
                prefixIcon: Icons.lock_outline_rounded,
                isObscure: _isObscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.iconColor,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscurePassword = !_isObscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.md),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _navigateToForgotPassword,
                  child: const Text(
                    'Lupa kata sandi?',
                    style: AppTextStyles.linkText,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              CustomButton(
                text: 'Masuk',
                isLoading: _isLoading,
                onPressed: _isGoogleLoading ? null : _onLogin,
              ),
              const SizedBox(height: 14),

              Row(
                children: const [
                  Expanded(child: Divider(color: AppColors.inputBorderColor)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'atau',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.inputBorderColor)),
                ],
              ),
              const SizedBox(height: 14),

              GoogleSignInButton(
                text: 'Masuk dengan Google',
                isLoading: _isGoogleLoading,
                onPressed: _isLoading ? null : _onGoogleSignIn,
              ),
              const SizedBox(height: AppDimensions.lg),

              Center(
                child: GestureDetector(
                  onTap: _navigateToRegister,
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.secondaryText,
                      ),
                      children: [
                        TextSpan(text: 'Belum punya akun? '),
                        TextSpan(
                          text: 'Daftar akun',
                          style: AppTextStyles.linkTextBold,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.lg),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.shield_outlined,
                      size: 15,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Data akunmu tersimpan aman di server BreakFree',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.securityNote,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
            ],
          ),
        ),
      ),
    );
  }
}
