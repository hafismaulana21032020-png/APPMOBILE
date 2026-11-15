import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/auth_header_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../account/domain/services/user_service.dart';
import '../widgets/auth_info_card.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;
  bool _isAgreed = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _onRegister() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('Silakan lengkapi semua data pendaftaran terlebih dahulu');
      return;
    }

    if (!AppValidators.isValidEmail(email)) {
      _showError('Format email tidak valid');
      return;
    }

    if (!AppValidators.isStrongPassword(password)) {
      _showError('Kata sandi minimal 8 karakter dan mengandung huruf serta angka');
      return;
    }

    if (password != confirmPassword) {
      _showError('Konfirmasi kata sandi tidak cocok');
      return;
    }

    if (!_isAgreed) {
      _showError('Silakan setujui Syarat dan Ketentuan terlebih dahulu');
      return;
    }

    final currentUser = UserService.instance;
    currentUser.updateProfile(
      name: name.toUpperCase(),
      email: email,
      phone: currentUser.phone,
      birthDate: currentUser.birthDate,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Akun berhasil dibuat! Selamat datang, $name'),
        backgroundColor: AppColors.primaryBrown,
        duration: const Duration(seconds: 1),
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
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
                onBackPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: AppDimensions.xxl),

              // Judul Pendaftaran
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

              // Card Promo Kecil
              const AuthInfoCard(
                icon: Icons.auto_awesome,
                title: 'Ngopi, kumpulkan poin, nikmati promo.',
                subtitle: 'Semua keuntungan dalam satu akun.',
              ),
              const SizedBox(height: AppDimensions.xl),

              // Input Nama Lengkap
              CustomTextField(
                label: 'Nama lengkap',
                controller: _nameController,
                hintText: 'Masukkan nama lengkap kamu',
                prefixIcon: Icons.person_outline,
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

              // Input Konfirmasi Kata Sandi
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

              // Checkbox Persetujuan Syarat & Ketentuan
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

              // Tombol Daftar
              CustomButton(
                text: 'Daftar',
                onPressed: _onRegister,
              ),
              const SizedBox(height: AppDimensions.xl),

              // Footer Pindah ke Login
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
