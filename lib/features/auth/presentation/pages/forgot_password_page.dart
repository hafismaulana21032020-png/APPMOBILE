import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/auth_header_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../widgets/auth_info_card.dart';
import '../widgets/otp_input_fields.dart';
import '../widgets/reset_password_success_dialog.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _currentStep = 1; // Step 1: Email, Step 2: OTP, Step 3: Password Baru

  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isObscureNewPassword = true;
  bool _isObscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan email kamu terlebih dahulu'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _currentStep = 2; // Pindah ke layar input OTP
    });
  }

  void _verifyOtp() {
    String otpCode = _otpControllers.map((e) => e.text).join();
    if (otpCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan 4 digit kode OTP dengan lengkap'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _currentStep = 3; // Pindah ke layar buat Kata Sandi Baru
    });
  }

  void _resetPassword() {
    if (_newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan isi kata sandi baru dan konfirmasinya'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi konfirmasi tidak cocok'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Modal Sukses Reset Kata Sandi
    ResetPasswordSuccessDialog.show(
      context,
      onLoginPressed: () {
        Navigator.pop(context); // Tutup Dialog
        Navigator.pop(context); // Kembali ke LoginPage
      },
    );
  }

  void _handleBack() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
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
                onBackPressed: _handleBack,
              ),
              const SizedBox(height: 28),

              // Render Tampilan Berdasarkan Step
              if (_currentStep == 1) _buildStep1Email(),
              if (_currentStep == 2) _buildStep2Otp(),
              if (_currentStep == 3) _buildStep3NewPassword(),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== STEP 1: INPUT EMAIL ====================
  Widget _buildStep1Email() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lupa kata sandi?',
          style: AppTextStyles.headingLarge,
        ),
        const SizedBox(height: 6),
        const Text(
          'Masukkan email kamu untuk menerima kode OTP verifikasi atur ulang kata sandi.',
          style: AppTextStyles.bodyDescription,
        ),
        const SizedBox(height: AppDimensions.xxl),

        // Card Info OTP
        const AuthInfoCard(
          icon: Icons.pin_outlined,
          title: 'Verifikasi Kode OTP',
          subtitle: 'Kami akan mengirim 4 digit kode OTP ke email kamu.',
        ),
        const SizedBox(height: AppDimensions.xxl),

        // Input Email
        CustomTextField(
          label: 'Email',
          controller: _emailController,
          hintText: 'Masukkan email terdaftar kamu',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 28),

        CustomButton(
          text: 'Kirim Kode OTP',
          onPressed: _sendOtp,
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
                  TextSpan(text: 'Ingat kata sandi? '),
                  TextSpan(
                    text: 'Masuk di sini',
                    style: AppTextStyles.linkTextBold,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== STEP 2: INPUT OTP ====================
  Widget _buildStep2Otp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Masukkan Kode OTP',
          style: AppTextStyles.headingLarge,
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: AppTextStyles.bodyDescription,
            children: [
              const TextSpan(text: 'Kode verifikasi telah dikirim ke '),
              TextSpan(
                text: _emailController.text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.xxxl),

        // 4 Box Input Kode OTP
        OtpInputFields(
          controllers: _otpControllers,
          focusNodes: _otpFocusNodes,
        ),
        const SizedBox(height: AppDimensions.xxxl),

        CustomButton(
          text: 'Verifikasi Kode',
          onPressed: _verifyOtp,
        ),
        const SizedBox(height: AppDimensions.xl),

        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Belum terima kode? ',
                style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kode OTP baru telah dikirim kembali'),
                      backgroundColor: AppColors.primaryBrown,
                    ),
                  );
                },
                child: const Text(
                  'Kirim Ulang',
                  style: AppTextStyles.linkTextBold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== STEP 3: KATA SANDI BARU ====================
  Widget _buildStep3NewPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buat Kata Sandi Baru',
          style: AppTextStyles.headingLarge,
        ),
        const SizedBox(height: 6),
        const Text(
          'Buat kata sandi baru yang kuat dan mudah kamu ingat.',
          style: AppTextStyles.bodyDescription,
        ),
        const SizedBox(height: AppDimensions.xxl),

        // Input Kata Sandi Baru
        CustomTextField(
          label: 'Kata sandi baru',
          controller: _newPasswordController,
          hintText: 'Masukkan kata sandi baru',
          prefixIcon: Icons.lock_outline,
          isObscure: _isObscureNewPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _isObscureNewPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.secondaryText,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isObscureNewPassword = !_isObscureNewPassword;
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

        // Input Konfirmasi Kata Sandi Baru
        CustomTextField(
          label: 'Konfirmasi kata sandi baru',
          controller: _confirmPasswordController,
          hintText: 'Ulangi kata sandi baru',
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
        const SizedBox(height: 28),

        CustomButton(
          text: 'Simpan Kata Sandi',
          onPressed: _resetPassword,
        ),
      ],
    );
  }
}
