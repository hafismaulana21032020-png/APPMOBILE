import 'package:flutter/foundation.dart';

enum PickupMode {
  dineIn(
    code: 'DINE_IN',
    label: 'Dine-in',
    displayTitle: 'Self Pick-Up • Dine-in',
    description: 'Nikmati di kedai, ambil sendiri di bar saat antrean dipanggil.',
    checkoutDescription: 'Dine-in (Minum di Kafe)',
  ),
  takeaway(
    code: 'TAKEAWAY',
    label: 'Takeaway',
    displayTitle: 'Self Pick-Up • Takeaway',
    description: 'Dikemas untuk dibawa pulang, ambil langsung di counter bar.',
    checkoutDescription: 'Takeaway (Bungkus Bawa Pulang)',
  );

  final String code;
  final String label;
  final String displayTitle;
  final String description;
  final String checkoutDescription;

  const PickupMode({
    required this.code,
    required this.label,
    required this.displayTitle,
    required this.description,
    required this.checkoutDescription,
  });
}

/// Mengelola status mode pengambilan pesanan mandiri (Self Pick-Up: Dine-in vs Takeaway) di Counter Bar BreakFree.
class PickupModeService extends ChangeNotifier {
  PickupModeService._();
  static final PickupModeService instance = PickupModeService._();

  PickupMode _mode = PickupMode.dineIn;

  PickupMode get mode => _mode;
  String get displayTitle => _mode.displayTitle;
  String get subtitle => 'Ambil di Counter • Ubah';
  bool get isDineIn => _mode == PickupMode.dineIn;
  bool get isTakeaway => _mode == PickupMode.takeaway;
  String get checkoutPickupType => _mode.checkoutDescription;

  void setMode(PickupMode newMode) {
    if (_mode == newMode) return;
    _mode = newMode;
    notifyListeners();
  }
}
