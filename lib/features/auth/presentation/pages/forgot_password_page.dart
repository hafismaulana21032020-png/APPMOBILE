import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/auth_header_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/password_similarity_warning_dialog.dart';
import '../../../account/domain/services/user_service.dart';
import '../widgets/coffee_banner.dart';

enum _ResetStep {
  enterEmail,
  verifyOtp,
  createNewPassword,
}

class ForgotPasswordPage extends StatefulWidget {
  final String? initialEmail;

  const ForgotPasswordPage({
    super.key,
    this.initialEmail,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  _ResetStep _step = _ResetStep.enterEmail;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _similarityWarning;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    final prefill = widget.initialEmail?.trim();
    if (prefill != null && prefill.isNotEmpty) {
      _emailController.text = prefill;
    }
    _newPasswordController.addListener(_clearSimilarityWarning);
    _confirmPasswordController.addListener(_clearSimilarityWarning);
  }

  void _clearSimilarityWarning() {
    if (_similarityWarning != null && mounted) {
      setState(() => _similarityWarning = null);
    }
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_clearSimilarityWarning);
    _confirmPasswordController.removeListener(_clearSimilarityWarning);
    _cooldownTimer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _resendCooldown = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFC93B2B) : const Color(0xFF2E7D32),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _onSendOtp({bool isResend = false}) async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('Silakan masukkan email Gmail kamu terlebih dahulu.', isError: true);
      return;
    }

    if (!AppValidators.isValidEmail(email)) {
      _showSnackBar('Format email tidak valid.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.instance.forgotPassword(email);
      if (res['success'] == true) {
        setState(() {
          _step = _ResetStep.verifyOtp;
          if (isResend) _otpController.clear();
        });
        _startResendCooldown();
        _showSnackBar(
          res['message']?.toString() ??
              'Kode OTP 6 digit telah dikirim ke Gmail kamu.',
        );
      } else {
        _showSnackBar(
          res['message']?.toString() ?? 'Gagal mengirim kode OTP.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Gagal menghubungi server: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onVerifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      _showSnackBar('Masukkan kode OTP 6 digit angka dari email Anda.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.instance.verifyResetOtp(
        email: email,
        otp: otp,
      );
      if (res['success'] == true && res['valid'] == true) {
        setState(() {
          _step = _ResetStep.createNewPassword;
        });
        _showSnackBar(
          res['message']?.toString() ??
              'Kode OTP cocok! Silakan buat kata sandi baru.',
        );
      } else {
        _showSnackBar(
          res['message']?.toString() ?? 'Kode OTP tidak sesuai atau sudah kedaluwarsa.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Gagal memverifikasi kode OTP: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onResetPassword({bool allowSimilar = false}) async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (!AppValidators.isStrongPassword(newPass)) {
      _showSnackBar(
        'Kata sandi baru minimal 8 karakter dan mengandung huruf serta angka.',
        isError: true,
      );
      return;
    }

    if (newPass != confirmPass) {
      _showSnackBar('Konfirmasi kata sandi tidak cocok.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      if (allowSimilar) _similarityWarning = null;
    });
    try {
      final res = await ApiService.instance.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPass,
        allowSimilar: allowSimilar,
      );
      if (res['success'] == true) {
        if (ApiService.instance.hasToken) {
          await UserService.instance.syncWithBackend();
        }
        _showSnackBar(
          res['message']?.toString() ?? 'Kata sandi berhasil diperbarui!',
        );
        if (mounted) Navigator.pop(context);
      } else if (res['code'] == 'PASSWORD_TOO_SIMILAR' && !allowSimilar && mounted) {
        final warningMsg = res['message']?.toString() ??
            'Peringatan: Kata sandi baru Anda hampir sama dengan kata sandi sebelumnya.';
        setState(() {
          _similarityWarning = warningMsg;
          _isLoading = false;
        });
        final proceedAnyway = await showPasswordSimilarityWarningDialog(
          context,
          customMessage: warningMsg,
        );
        if (proceedAnyway && mounted) {
          await _onResetPassword(allowSimilar: true);
        }
        return;
      } else {
        final msg = res['message']?.toString() ?? 'Gagal memperbarui kata sandi.';
        if (res['code'] == 'PASSWORD_SAME' && mounted) {
          setState(() => _similarityWarning = msg);
        }
        _showSnackBar(msg, isError: true);
      }
    } catch (e) {
      _showSnackBar('Gagal terhubung ke server: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _subtitleText {
    switch (_step) {
      case _ResetStep.enterEmail:
        return 'Masukkan email Gmail terdaftar Anda. Kami akan mengirimkan kode OTP 6 digit ke email tersebut.';
      case _ResetStep.verifyOtp:
        return 'Periksa Kotak Masuk atau folder Spam Gmail Anda, lalu masukkan kode OTP 6 digit di bawah ini.';
      case _ResetStep.createNewPassword:
        return 'Kode OTP sudah terverifikasi! Silakan buat kata sandi baru untuk akun Anda.';
    }
  }

  String get _buttonText {
    switch (_step) {
      case _ResetStep.enterEmail:
        return 'Kirim Kode OTP ke Email';
      case _ResetStep.verifyOtp:
        return 'Verifikasi Kode OTP';
      case _ResetStep.createNewPassword:
        return 'Simpan Kata Sandi Baru';
    }
  }

  VoidCallback get _primaryAction {
    switch (_step) {
      case _ResetStep.enterEmail:
        return () => _onSendOtp();
      case _ResetStep.verifyOtp:
        return _onVerifyOtp;
      case _ResetStep.createNewPassword:
        return _onResetPassword;
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
                'Lupa kata sandi?',
                style: AppTextStyles.headingLarge,
              ),
              const SizedBox(height: 6),
              Text(
                _subtitleText,
                style: AppTextStyles.bodyDescription,
              ),
              const SizedBox(height: AppDimensions.md),

              // Step Indicator Pills
              Row(
                children: [
                  _buildStepChip('1. Email', _step == _ResetStep.enterEmail, _step.index > 0),
                  const SizedBox(width: 6),
                  _buildStepChip('2. Kode OTP', _step == _ResetStep.verifyOtp, _step.index > 1),
                  const SizedBox(width: 6),
                  _buildStepChip('3. Sandi Baru', _step == _ResetStep.createNewPassword, false),
                ],
              ),
              const SizedBox(height: AppDimensions.xl),

              if (_step == _ResetStep.enterEmail)
                CustomTextField(
                  label: 'Email Gmail',
                  controller: _emailController,
                  hintText: 'contoh@gmail.com',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),

              if (_step == _ResetStep.verifyOtp) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF90CAF9)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mark_email_read_outlined, size: 20, color: Color(0xFF1565C0)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OTP dikirim ke ${_emailController.text.trim()}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                            const SizedBox(height: 2),
                            GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      _cooldownTimer?.cancel();
                                      setState(() {
                                        _step = _ResetStep.enterEmail;
                                        _otpController.clear();
                                        _resendCooldown = 0;
                                      });
                                    },
                              child: const Text(
                                'Ubah alamat email',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1565C0),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),
                CustomTextField(
                  label: 'Kode OTP (6 digit)',
                  controller: _otpController,
                  hintText: 'Masukkan 6 digit kode OTP dari Gmail',
                  prefixIcon: Icons.pin_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: _resendCooldown > 0
                      ? Text(
                          'Kirim ulang kode dalam $_resendCooldown dtk',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        )
                      : GestureDetector(
                          onTap: _isLoading ? null : () => _onSendOtp(isResend: true),
                          child: const Text(
                            'Kirim ulang kode OTP',
                            style: AppTextStyles.linkTextBold,
                          ),
                        ),
                ),
              ],

              if (_step == _ResetStep.createNewPassword) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 18, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kode OTP terverifikasi (${_emailController.text.trim()})',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),
                CustomTextField(
                  label: 'Kata sandi baru',
                  controller: _newPasswordController,
                  hintText: 'Min. 8 karakter (huruf & angka)',
                  prefixIcon: Icons.lock_outline_rounded,
                  isObscure: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.iconColor,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),
                CustomTextField(
                  label: 'Konfirmasi kata sandi baru',
                  controller: _confirmPasswordController,
                  hintText: 'Ulangi kata sandi baru',
                  prefixIcon: Icons.lock_outline_rounded,
                  isObscure: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.iconColor,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword,
                      );
                    },
                  ),
                ),
                if (_similarityWarning != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFCA28)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 20,
                          color: Color(0xFFEF6C00),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _similarityWarning!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8D4E00),
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              const SizedBox(height: AppDimensions.xxl),

              CustomButton(
                text: _buttonText,
                isLoading: _isLoading,
                onPressed: _primaryAction,
              ),
              const SizedBox(height: AppDimensions.xl),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: AppColors.darkBrown,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.initialEmail != null ? 'Kembali' : 'Kembali ke Masuk',
                        style: AppTextStyles.linkTextBold,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.xxxl),

              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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

  Widget _buildStepChip(String label, bool isActive, bool isCompleted) {
    final bgColor = isCompleted
        ? const Color(0xFFE8F5E9)
        : (isActive ? AppColors.primaryBrown : Colors.white);
    final borderColor = isCompleted
        ? const Color(0xFF81C784)
        : (isActive ? AppColors.primaryBrown : AppColors.inputBorderColor);
    final textColor = isCompleted
        ? const Color(0xFF2E7D32)
        : (isActive ? Colors.white : AppColors.secondaryText);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
