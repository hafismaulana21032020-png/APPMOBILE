import '../../../../core/utils/app_formatters.dart';

class CartItemModel {
  final String id;
  final String name;
  final String options;
  final int price;
  int quantity;
  final String image;

  CartItemModel({
    required this.id,
    required this.name,
    required this.options,
    required this.price,
    this.quantity = 1,
    required this.image,
  });

  int get totalPrice => price * quantity;

  String get formattedPrice => AppFormatters.formatRupiah(price);
}

