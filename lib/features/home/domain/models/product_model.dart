class ProductModel {
  final String id;
  final String name;
  final int price;
  final String category;
  final String image;
  final String description;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    this.description = '',
  });

  String get formattedPrice {
    final priceStr = price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return 'Rp $priceStr';
  }
}
