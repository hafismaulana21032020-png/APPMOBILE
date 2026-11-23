import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/chat_message_model.dart';
import '../../domain/models/product_model.dart';
import '../../domain/services/ai_chat_service.dart';
import 'product_order_bottom_sheet.dart';

/// Interactive Chat View component for BreakFree Barista AI.
/// Usable both in a bottom sheet and inside a full screen page.
class AiChatView extends StatefulWidget {
  final bool isFullScreen;
  final VoidCallback? onOpenFullScreen;
  final VoidCallback? onClose;
  final FocusNode? focusNode;

  const AiChatView({
    super.key,
    this.isFullScreen = false,
    this.onOpenFullScreen,
    this.onClose,
    this.focusNode,
  });

  @override
  State<AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<AiChatView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final FocusNode _focusNode;
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _textController.addListener(_onTextChanged);
    AiChatService.instance.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    AiChatService.instance.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _canSend) {
      setState(() {
        _canSend = hasText;
      });
    }
  }

  void _onServiceUpdate() {
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void _sendMessage([String? predefinedText]) {
    final query = predefinedText ?? _textController.text;
    if (query.trim().isEmpty) return;

    if (predefinedText == null) {
      _textController.clear();
    }
    AiChatService.instance.sendMessage(query);
  }

  void _addToCart(ProductModel product) {
    ProductOrderBottomSheet.show(context, product);
  }

  void _confirmResetChat() {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Mulai Obrolan Baru?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        content: const Text(
          'Riwayat obrolan dengan Barista AI saat ini akan dihapus dan dimulai dari awal.',
          style: TextStyle(fontSize: 13.5, color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              AiChatService.instance.resetChat();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Mulai Baru',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = AiChatService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final messages = service.messages;
        final isTyping = service.isTyping;

        // Extract latest quick suggestions from last bot message or defaults
        List<String> currentQuickReplies = AiChatService.defaultQuickSuggestions;
        if (messages.isNotEmpty) {
          final lastBot = messages.reversed.firstWhere(
            (m) => !m.isUser && m.quickReplies.isNotEmpty,
            orElse: () => messages.first,
          );
          if (lastBot.quickReplies.isNotEmpty) {
            currentQuickReplies = lastBot.quickReplies;
          }
        }

        return Column(
          children: [
            // Header if not in full screen (or if requested)
            if (!widget.isFullScreen) _buildSheetHeader(),

            // Chat Message List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < messages.length) {
                    final message = messages[index];
                    return _buildMessageItem(message);
                  } else {
                    return _buildTypingIndicator();
                  }
                },
              ),
            ),

            // Quick Suggestion Chips Row
            _buildQuickSuggestionsBar(currentQuickReplies),

            // Bottom Input Bar
            _buildInputBar(),
          ],
        );
      },
    );
  }

  Widget _buildSheetHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.inputBorderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primaryBrown,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Barista AI BreakFree',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    _OnlineBadge(),
                  ],
                ),
                Text(
                  'Tanya menu, rekomendasi rasa & promo',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Mulai obrolan baru',
            icon: const Icon(
              Icons.restart_alt_rounded,
              color: AppColors.secondaryText,
              size: 20,
            ),
            onPressed: _confirmResetChat,
          ),
          if (widget.onOpenFullScreen != null)
            IconButton(
              tooltip: 'Layar Penuh',
              icon: const Icon(
                Icons.open_in_full_rounded,
                color: AppColors.secondaryText,
                size: 19,
              ),
              onPressed: widget.onOpenFullScreen,
            ),
          if (widget.onClose != null)
            IconButton(
              tooltip: 'Tutup',
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.secondaryText,
                size: 22,
              ),
              onPressed: widget.onClose,
            ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    if (message.isUser) {
      return _buildUserBubble(message);
    } else {
      return _buildBotBubble(message);
    }
  }

  Widget _buildUserBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.76,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.primaryBrown,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Colors.white,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2, right: 8),
            decoration: const BoxDecoration(
              color: AppColors.primaryBrown,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(
                      color: AppColors.inputBorderColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildRichText(message.text),
                ),

                // Attached products if any
                if (message.products.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...message.products.map(
                    (product) => _buildProductRecommendationCard(product),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRecommendationCard(ProductModel product) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _addToCart(product),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.inputBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildProductThumbnail(product.image),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.formattedPrice,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBrown,
                      ),
                    ),
                    if (product.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _addToCart(product),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrown,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '+ Tambah',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductThumbnail(String rawImage) {
    final img = rawImage.trim();
    if (img.startsWith('http://') || img.startsWith('https://')) {
      return Image.network(
        img,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackThumbnail(),
      );
    }
    return Image.asset(
      img.isNotEmpty ? img : AppAssets.breakfreeArenLatte,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildFallbackThumbnail(),
    );
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      width: 50,
      height: 50,
      color: AppColors.cardBgColor,
      child: const Icon(
        Icons.coffee_rounded,
        color: AppColors.primaryBrown,
        size: 24,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2, right: 8),
            decoration: const BoxDecoration(
              color: AppColors.primaryBrown,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputBorderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryBrown,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Barista AI sedang mengetik...',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.secondaryText.withAlpha(220),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestionsBar(List<String> suggestions) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 42,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          final cleanText = _cleanSuggestionLabel(suggestion);
          final icon = _getSuggestionIcon(suggestion);

          return ActionChip(
            avatar: Icon(
              icon,
              size: 15,
              color: AppColors.primaryBrown,
            ),
            label: Text(
              cleanText,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBrown,
              ),
            ),
            backgroundColor: AppColors.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(
                color: AppColors.inputBorderColor,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            onPressed: () => _sendMessage(cleanText),
          );
        },
      ),
    );
  }

  IconData _getSuggestionIcon(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('manis') || lower.contains('creamy') || lower.contains('aren')) {
      return Icons.local_cafe_rounded;
    }
    if (lower.contains('strong') || lower.contains('nugas') || lower.contains('hitam') || lower.contains('kafein')) {
      return Icons.bolt_rounded;
    }
    if (lower.contains('non-kopi') || lower.contains('segar') || lower.contains('buah') || lower.contains('tea')) {
      return Icons.local_drink_rounded;
    }
    if (lower.contains('makan') || lower.contains('lapar') || lower.contains('mie') || lower.contains('nasi')) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains('camilan') || lower.contains('snack') || lower.contains('ngemil') || lower.contains('fries')) {
      return Icons.fastfood_rounded;
    }
    if (lower.contains('promo') || lower.contains('voucher') || lower.contains('diskon') || lower.contains('break20')) {
      return Icons.local_offer_rounded;
    }
    if (lower.contains('jam') || lower.contains('wifi') || lower.contains('wi-fi') || lower.contains('lokasi')) {
      return Icons.schedule_rounded;
    }
    if (lower.contains('lacak') || lower.contains('status')) {
      return Icons.location_searching_rounded;
    }
    if (lower.contains('lambung') || lower.contains('aman')) {
      return Icons.favorite_rounded;
    }
    return Icons.auto_awesome;
  }

  String _cleanSuggestionLabel(String text) {
    return text.replaceAll(RegExp(r'^[^\w\s\d]+'), '').trim();
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        14,
        10,
        14,
        12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.inputBorderColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.inputBorderColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  minLines: 1,
                  maxLines: 4,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.darkText,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Tanya Barista AI tentang menu, rasa, promo...',
                    hintStyle: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.hintColor,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _canSend ? () => _sendMessage() : null,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _canSend
                      ? AppColors.primaryBrown
                      : AppColors.primaryBrown.withAlpha(80),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRichText(String text) {
    // Basic markdown-like parser for **bold** text and newlines
    final spans = <InlineSpan>[];
    final parts = text.split('**');

    for (int i = 0; i < parts.length; i++) {
      final isBold = i % 2 == 1;
      spans.add(
        TextSpan(
          text: parts[i],
          style: TextStyle(
            fontSize: 13.5,
            color: AppColors.darkText,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            height: 1.45,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  const _OnlineBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 3,
            backgroundColor: Color(0xFF4CAF50),
          ),
          SizedBox(width: 4),
          Text(
            'Online',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}
