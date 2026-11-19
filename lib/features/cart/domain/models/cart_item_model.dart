import '../../../../core/utils/app_formatters.dart';

class CartItemModel {
  final String id;
  final String name;
  final String options;
  final int price;
  int quantity;
  final String image;
  final String? note;

  CartItemModel({
    required this.id,
    required this.name,
    required this.options,
    required this.price,
    this.quantity = 1,
    required this.image,
    this.note,
  });

  int get totalPrice => price * quantity;

  String get formattedPrice => AppFormatters.formatRupiah(price);
}

