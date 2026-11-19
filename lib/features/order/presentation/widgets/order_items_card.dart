import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../cart/domain/models/cart_item_model.dart';
import '../../domain/models/order_model.dart';

/// Card displaying list of items, payment method, and financial breakdown for an order.
class OrderItemsCard extends StatelessWidget {
  final OrderModel order;

  const OrderItemsCard({
    super.key,
    required this.order,
  });

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} • $h:$m WIB';
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = order.items.fold<int>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final discount = order.promoCode != null ? (subtotal * 0.20).round() : 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_outlined,
                size: 20,
                color: AppColors.primaryBrown,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Rincian Menu',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              Text(
                '${order.totalItemCount} Item',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Item tiles
          ...order.items.map((item) => _buildOrderItemTile(item)),

          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.inputBorderColor),
          const SizedBox(height: 12),

          // Payment details
          _buildRow('Waktu Pesanan', _formatDateTime(order.createdAt)),
          const SizedBox(height: 6),
          _buildRow('Metode Pembayaran', order.paymentMethod, isBoldValue: true),
          if (order.promoCode != null) ...[
            const SizedBox(height: 6),
            _buildRow(
              'Voucher (${order.promoCode})',
              '- ${AppFormatters.formatRupiah(discount)}',
              valueColor: const Color(0xFF2E7D32),
            ),
          ],
          const SizedBox(height: 6),
          _buildRow(
            'Total Pembayaran',
            order.formattedTotalPrice,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemTile(CartItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.image,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 44,
                height: 44,
                color: AppColors.cardBgColor,
                child: const Icon(
                  Icons.coffee_rounded,
                  color: AppColors.primaryBrown,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${item.quantity}x ',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBrown,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.options.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.options,
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
          Text(
            AppFormatters.formatRupiah(item.price * item.quantity),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isBoldValue = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.darkText : AppColors.secondaryText,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTotal ? 15 : 12.5,
              fontWeight:
                  isTotal || isBoldValue ? FontWeight.bold : FontWeight.w500,
              color: valueColor ??
                  (isTotal ? AppColors.darkBrown : AppColors.darkText),
            ),
          ),
        ),
      ],
    );
  }
}
