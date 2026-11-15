class AppFormatters {
  AppFormatters._();

  static final RegExp _thousandsRegex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

  /// Formats an integer with dot thousand separators (e.g. `1240` -> `'1.240'`).
  static String formatThousands(int value) {
    final isNegative = value < 0;
    final digits = value.abs().toString().replaceAllMapped(
          _thousandsRegex,
          (Match m) => '${m[1]}.',
        );
    return isNegative ? '-$digits' : digits;
  }

  /// Formats an integer amount into Rupiah currency (e.g. `25000` -> `'Rp 25.000'`).
  static String formatRupiah(int amount) {
    if (amount < 0) {
      return '-Rp ${formatThousands(amount.abs())}';
    }
    return 'Rp ${formatThousands(amount)}';
  }
}

