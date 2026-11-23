import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_formatters.dart';

class ProductModel {
  final String id;
  final String name;
  final int price;
  final String category;
  final String image;
  final String description;
  final String? subcategory;
  final String? tag;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    this.description = '',
    this.subcategory,
    this.tag,
  });

  String get formattedPrice => AppFormatters.formatRupiah(price);

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image']?.toString() ?? json['imageUrl']?.toString() ?? '';
    final image = rawImage.trim().isNotEmpty ? rawImage.trim() : AppAssets.breakfreeArenLatte;

    int parsePrice(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) {
        final parsed = double.tryParse(val) ?? int.tryParse(val);
        if (parsed != null) return parsed.toInt();
      }
      return 0;
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: parsePrice(json['price']),
      category: json['category']?.toString() ?? 'Coffee',
      image: image,
      description: json['description']?.toString() ?? '',
      subcategory: json['subcategory']?.toString(),
      tag: json['tag']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'image': image,
      'description': description,
      'subcategory': subcategory,
      'tag': tag,
    };
  }
}
