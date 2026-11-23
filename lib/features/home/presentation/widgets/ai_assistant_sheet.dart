import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/menu_data.dart';
import '../../domain/models/product_model.dart';
import 'ai_chat_view.dart';
import 'product_order_bottom_sheet.dart';

/// Displays the BreakFree AI Barista assistant bottom sheet with
/// both interactive Chatbot capability and Quick Recommendations.
void showAiAssistantSheet(BuildContext context, {int initialTabIndex = 0}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) {
      return AiAssistantSheetContent(initialTabIndex: initialTabIndex);
    },
  );
}

class AiAssistantSheetContent extends StatefulWidget {
  final int initialTabIndex;

  const AiAssistantSheetContent({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<AiAssistantSheetContent> createState() => _AiAssistantSheetContentState();
}

class _AiAssistantSheetContentState extends State<AiAssistantSheetContent> {
  late int _selectedTab;
  final FocusNode _chatFocusNode = FocusNode();

  List<ProductModel> _recommendations = [];
  bool _isLoadingRecommendations = true;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
    _fetchRecommendations();
  }

  @override
  void dispose() {
    _chatFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchRecommendations() async {
    setState(() {
      _isLoadingRecommendations = true;
    });
    try {
      final res = await ApiService.instance.getBaristaRecommendations();
      if (res['success'] == true && res['data'] is List) {
        final list = (res['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductModel.fromJson(json))
            .toList();
        if (list.isNotEmpty && mounted) {
          setState(() {
            _recommendations = list;
            _isLoadingRecommendations = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error fetching recommendations: $e');
    }
    if (mounted) {
      setState(() {
        if (_recommendations.isEmpty) {
          _recommendations = _getFallbackRecommendations();
        }
        _isLoadingRecommendations = false;
      });
    }
  }

  List<ProductModel> _getFallbackRecommendations() {
    return [
      breakfreeMenuItems.firstWhere(
        (p) => p.id == 'ic-3',
        orElse: () => breakfreeMenuItems.first,
      ),
      breakfreeMenuItems.firstWhere(
        (p) => p.id == 'nk-s-5',
        orElse: () => breakfreeMenuItems.first,
      ),
      breakfreeMenuItems.firstWhere(
        (p) => p.id == 'm-np-2',
        orElse: () => breakfreeMenuItems.first,
      ),
      breakfreeMenuItems.firstWhere(
        (p) => p.id == 'snack-2',
        orElse: () => breakfreeMenuItems.first,
      ),
    ];
  }

  void _onAddToCart(ProductModel product) {
    ProductOrderBottomSheet.show(context, product);
  }

  void _openFullScreenChat() {
    Navigator.pop(context);
    Navigator.pushNamed(context, AppRoutes.aiChat);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final sheetHeight = mediaQuery.size.height * 0.88;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag handle pill
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inputBorderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Top Tab Selector: [ 💬 Chatbot AI ]  [ ⭐ Rekomendasi Cepat ]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.inputBorderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabPill(
                        index: 0,
                        icon: Icons.chat_bubble_outline_rounded,
                        activeIcon: Icons.chat_bubble_rounded,
                        label: 'Chat Barista AI',
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildTabPill(
                        index: 1,
                        icon: Icons.auto_awesome_outlined,
                        activeIcon: Icons.auto_awesome,
                        label: 'Rekomendasi',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Tab Content
            Expanded(
              child: _selectedTab == 0
                  ? AiChatView(
                      focusNode: _chatFocusNode,
                      onOpenFullScreen: _openFullScreenChat,
                      onClose: () => Navigator.pop(context),
                    )
                  : _buildRecommendationsView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _selectedTab == index;

    return InkWell(
      onTap: () {
        if (_selectedTab != index) {
          setState(() {
            _selectedTab = index;
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBrown : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.secondaryText,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner invite to Chat Bot
          InkWell(
            onTap: () {
              setState(() {
                _selectedTab = 0;
              });
              Future.delayed(const Duration(milliseconds: 150), () {
                if (mounted) {
                  _chatFocusNode.requestFocus();
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.cardBgColor,
                    Color(0xFFEFE6D8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryBrown.withAlpha(40),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBrown,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Punya Pertanyaan Selera Khusus?',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBrown,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tanya Barista AI untuk rekomendasi rasa, kafein, promo, dan camilan favoritmu.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.secondaryText,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.darkBrown,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Menu Pilihan Barista Hari Ini',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Terfavorit',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Kurasi menu terlaris yang paling banyak dinikmati di BreakFree',
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 12),

          if (_isLoadingRecommendations)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryBrown,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Menyiapkan rekomendasi barista terlaris...',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.secondaryText.withAlpha(220),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._recommendations.map(
              (product) => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onAddToCart(product),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.inputBorderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.5,
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
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _onAddToCart(product),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBrown,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '+ Tambah',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductThumbnail(String rawImage) {
    final img = rawImage.trim();
    if (img.startsWith('http://') || img.startsWith('https://')) {
      return Image.network(
        img,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackThumbnail(),
      );
    }
    return Image.asset(
      img.isNotEmpty ? img : AppAssets.breakfreeArenLatte,
      width: 48,
      height: 48,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildFallbackThumbnail(),
    );
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      width: 48,
      height: 48,
      color: AppColors.cardBgColor,
      child: const Icon(
        Icons.coffee_rounded,
        color: AppColors.primaryBrown,
        size: 22,
      ),
    );
  }
}
