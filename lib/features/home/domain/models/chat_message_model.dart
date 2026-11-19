import '../../domain/models/product_model.dart';

/// Represents a message in the BreakFree AI Barista chat.
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<ProductModel> products;
  final List<String> quickReplies;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.products = const [],
    this.quickReplies = const [],
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    List<ProductModel>? products,
    List<String>? quickReplies,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      products: products ?? this.products,
      quickReplies: quickReplies ?? this.quickReplies,
    );
  }
}
