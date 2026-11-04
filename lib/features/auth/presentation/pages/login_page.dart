import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/auth_header_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import 'package:breakfree_app/features/home/presentation/pages/home_page.dart';
import '../widgets/coffee_banner.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Akun Dummy default agar bisa langsung dites
  final TextEditingController _emailController =
      TextEditingController(text: 'breakfree@gmail.com');
  final TextEditingController _passwordController =
      TextEditingController(text: 'kopi1234');
  bool _isObscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan email dan kata sandi terlebih dahulu'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil masuk! Selamat datang, $email'),
        backgroundColor: AppColors.primaryBrown,
        duration: const Duration(seconds: 1),
      ),
    );

    // Navigasi langsung ke HomePage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.xxl,
            vertical: AppDimensions.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header Bar
              AuthHeaderBar(
                onBackPressed: () {},
              ),
              const SizedBox(height: AppDimensions.xl),

              // Banner Gambar Kopi
              const CoffeeBanner(),
              const SizedBox(height: AppDimensions.xxl),

              // Judul Halaman
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

              // Info Box Akun Demo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inputBorderColor, width: 1.2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.key_rounded,
                      size: 20,
                      color: AppColors.primaryBrown,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Akun Demo (Otomatis Terisi):',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBrown,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Email: breakfree@gmail.com\nSandi: kopi1234',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.darkText,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.lg),

              // Input Email
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                hintText: 'Masukkan email kamu',
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppDimensions.lg),

              // Input Kata Sandi
              CustomTextField(
                label: 'Kata sandi',
                controller: _passwordController,
                hintText: 'Masukkan kata sandi',
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
              const SizedBox(height: AppDimensions.sm),

              // Lupa Kata Sandi
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
              const SizedBox(height: AppDimensions.xxl),

              // Tombol Masuk
              CustomButton(
                text: 'Masuk',
                onPressed: _onLogin,
              ),
              const SizedBox(height: AppDimensions.xl),

              // Footer Pindah ke Register Page
              Center(
                child: GestureDetector(
                  onTap: _navigateToRegister,
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 13,
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
            ],
          ),
        ),
      ),
    );
  }
}
