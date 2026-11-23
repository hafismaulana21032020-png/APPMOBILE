class PromoModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final String type; // 'PERCENTAGE' or 'FIXED'
  final int value;
  final int minPurchase;
  final int? maxDiscount;
  final bool isActive;

  const PromoModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    required this.minPurchase,
    this.maxDiscount,
    this.isActive = true,
  });

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val, [int def = 0]) {
      if (val is num) return val.toInt();
      if (val is String) {
        final parsed = double.tryParse(val) ?? int.tryParse(val);
        if (parsed != null) return parsed.toInt();
      }
      return def;
    }

    final rawType = (json['type'] ?? json['discount_type'] ?? 'PERCENTAGE').toString().toUpperCase();
    final type = rawType.contains('FIXED') ? 'FIXED' : 'PERCENTAGE';

    return PromoModel(
      id: json['id']?.toString() ?? '',
      code: (json['code']?.toString() ?? 'PROMO').toUpperCase(),
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Promo Spesial',
      description: json['description']?.toString() ?? 'Voucher diskon spesial untuk jedamu.',
      type: type,
      value: parseInt(json['value'] ?? json['discount_value']),
      minPurchase: parseInt(json['min_purchase'] ?? json['minPurchase'] ?? json['min_order']),
      maxDiscount: json['max_discount'] != null ? parseInt(json['max_discount']) : null,
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['isActive'] == true,
    );
  }
}
