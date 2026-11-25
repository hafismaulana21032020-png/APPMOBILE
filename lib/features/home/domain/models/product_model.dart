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
  final bool isAvailable;
  final bool isFavorite;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    this.description = '',
    this.subcategory,
    this.tag,
    this.isAvailable = true,
    this.isFavorite = false,
  });

  String get formattedPrice => AppFormatters.formatRupiah(price);

  ProductModel copyWith({
    String? id,
    String? name,
    int? price,
    String? category,
    String? image,
    String? description,
    String? subcategory,
    String? tag,
    bool? isAvailable,
    bool? isFavorite,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      image: image ?? this.image,
      description: description ?? this.description,
      subcategory: subcategory ?? this.subcategory,
      tag: tag ?? this.tag,
      isAvailable: isAvailable ?? this.isAvailable,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

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

    final rawAvailable = json['isAvailable'] ?? json['is_available'];
    final bool available = rawAvailable == null
        ? true
        : (rawAvailable is bool
            ? rawAvailable
            : (rawAvailable is num
                ? rawAvailable == 1
                : rawAvailable.toString() == '1' || rawAvailable.toString().toLowerCase() == 'true'));

    final rawFav = json['isFavorite'] ?? json['is_favorite'];
    final bool fav = rawFav == true || rawFav == 1 || rawFav?.toString() == '1';

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: parsePrice(json['price']),
      category: json['category']?.toString() ?? 'Coffee',
      image: image,
      description: json['description']?.toString() ?? '',
      subcategory: json['subcategory']?.toString(),
      tag: json['tag']?.toString(),
      isAvailable: available,
      isFavorite: fav,
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
      'isAvailable': isAvailable,
      'isFavorite': isFavorite,
    };
  }
}
