import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Menampilkan dialog peringatan saat kata sandi baru hampir sama dengan kata sandi sebelumnya.
/// Mengembalikan `true` jika pengguna memilih "Tetap Simpan", atau `false` jika memilih ubah ulang.
Future<bool> showPasswordSimilarityWarningDialog(
  BuildContext context, {
  String? customMessage,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFEF6C00),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Kata Sandi Hampir Sama',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        customMessage ??
            'Kata sandi baru yang kamu masukkan hampir sama dengan kata sandi sebelumnya. '
                'Demi keamanan akun BreakFree-mu, kami menyarankan untuk menggunakan kombinasi yang lebih berbeda.',
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.secondaryText,
          height: 1.45,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx, true),
          child: const Text(
            'Tetap Simpan',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogCtx, false),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBrown,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Ubah Kata Sandi',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
  return result == true;
}
