import 'package:flutter/material.dart';
import '../../domain/models/product_model.dart';
import '../../domain/services/favorite_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Tombol hati reaktif untuk toggle menu favorit dengan Optimistic UI Update.
class FavoriteHeartButton extends StatelessWidget {
  final ProductModel product;
  final double size;
  final bool withBackground;

  const FavoriteHeartButton({
    super.key,
    required this.product,
    this.size = 18,
    this.withBackground = true,
  });

  Future<void> _onPressed(BuildContext context) async {
    final res = await FavoriteService.instance.toggleFavorite(product);
    if (!context.mounted) return;
    if (res['success'] != true) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']?.toString() ?? 'Gagal memperbarui favorit'),
          backgroundColor: const Color(0xFFC93B2B),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FavoriteService.instance,
      builder: (context, _) {
        final isFav = FavoriteService.instance.isFavorite(product.id, product.name);
        return GestureDetector(
          onTap: () => _onPressed(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.all(withBackground ? 5 : 4),
            decoration: withBackground
                ? BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  )
                : null,
            child: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: size,
              color: isFav ? const Color(0xFFD32F2F) : AppColors.secondaryText,
            ),
          ),
        );
      },
    );
  }
}
