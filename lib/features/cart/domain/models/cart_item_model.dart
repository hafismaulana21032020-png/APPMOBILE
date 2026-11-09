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

  String get formattedPrice {
    final str = price.toString();
    if (str.length <= 3) return 'Rp $str';
    final thousands = str.substring(0, str.length - 3);
    final rest = str.substring(str.length - 3);
    return 'Rp $thousands.$rest';
  }
}

