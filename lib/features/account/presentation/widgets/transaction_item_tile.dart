import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TransactionItemTile extends StatelessWidget {
  final String orderId;
  final String dateTime;
  final int amount;
  final String status;

  const TransactionItemTile({
    super.key,
    required this.orderId,
    required this.dateTime,
    required this.amount,
    this.status = 'Selesai',
  });

  String _formatPrice(int price) {
    final str = price.toString();
    if (str.length <= 3) return 'Rp $str';
    final thousands = str.substring(0, str.length - 3);
    final rest = str.substring(str.length - 3);
    return 'Rp $thousands.$rest';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Receipt Icon Box
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.cardBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.receipt_rounded,
              size: 18,
              color: AppColors.primaryBrown,
            ),
          ),
          const SizedBox(width: 12),

          // Order ID + date info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderId,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateTime,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          // Amount + Status badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatPrice(amount),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF388E3C),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

