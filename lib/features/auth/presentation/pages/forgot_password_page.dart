import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/auth_header_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../widgets/coffee_banner.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendResetLink() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan email kamu terlebih dahulu'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!AppValidators.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulasi pengiriman tautan reset
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tautan reset kata sandi telah dikirim ke $email'),
          backgroundColor: AppColors.primaryBrown,
          duration: const Duration(seconds: 2),
        ),
      );
    });
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
              // Header Brand (BreakFree - Malang, Indonesia)
              const AuthHeaderBar(
                showBackButton: false,
              ),
              const SizedBox(height: AppDimensions.md),

              // Banner Gambar Kopi
              const CoffeeBanner(),
              const SizedBox(height: AppDimensions.xl),

              // Judul Halaman
              const Text(
                'Lupa kata sandi?',
                style: AppTextStyles.headingLarge,
              ),
              const SizedBox(height: 6),

              // Deskripsi
              const Text(
                'Masukkan email yang terdaftar di akunmu. Kami akan mengirimkan tautan untuk mengatur ulang kata sandi.',
                style: AppTextStyles.bodyDescription,
              ),
              const SizedBox(height: AppDimensions.xl),

              // Input Email
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                hintText: 'Masukkan email kamu',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppDimensions.xxl),

              // Tombol Kirim Tautan Reset
              CustomButton(
                text: 'Kirim Tautan Reset',
                isLoading: _isLoading,
                onPressed: _onSendResetLink,
              ),
              const SizedBox(height: AppDimensions.xl),

              // Kembali ke Masuk
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: AppColors.darkBrown,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Kembali ke Masuk',
                        style: AppTextStyles.linkTextBold,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.xxxl),

              // Catatan Keamanan Data
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
                        'Data akunmu tersimpan dengan aman',
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
