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
}
