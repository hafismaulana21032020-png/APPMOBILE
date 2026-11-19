import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/order_model.dart';

/// Hero live status card showing queue code, estimated time, and barista notes.
class OrderLiveStatusHero extends StatelessWidget {
  final OrderModel order;

  const OrderLiveStatusHero({
    super.key,
    required this.order,
  });

  void _copyOrderId(BuildContext context) {
    Clipboard.setData(ClipboardData(text: order.id));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nomor pesanan ${order.id} berhasil disalin!'),
        backgroundColor: AppColors.primaryBrown,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = order.status;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Live badge & Order ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: _buildLiveBadge()),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _copyOrderId(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        order.id,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.copy_rounded,
                        size: 14,
                        color: AppColors.secondaryText,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Big Queue Number & Counter Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.cardBgColor,
                  Color(0xFFEFE7DB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryBrown.withAlpha(40)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NOMOR ANTREAN',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryText,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.queueNumber,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.storefront_rounded,
                            size: 14,
                            color: AppColors.primaryBrown,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${order.counterName} • ${order.pickupType}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrown,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBrown.withAlpha(60),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      status.icon,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Live Headline & Subtitle
          Text(
            status.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status.subtitle,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.secondaryText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),

          // Estimated Time / Payment Instruction Badge
          if (status != OrderStatus.selesai)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: status == OrderStatus.siapDiambil
                    ? const Color(0xFFE8F5E9)
                    : (status == OrderStatus.menungguPembayaran
                        ? const Color(0xFFFFF8E1)
                        : AppColors.backgroundColor),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: status == OrderStatus.siapDiambil
                      ? const Color(0xFF81C784)
                      : (status == OrderStatus.menungguPembayaran
                          ? const Color(0xFFFFD54F)
                          : AppColors.inputBorderColor),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    status == OrderStatus.siapDiambil
                        ? Icons.check_circle_outline_rounded
                        : (status == OrderStatus.menungguPembayaran
                            ? Icons.payments_outlined
                            : Icons.timer_outlined),
                    size: 16,
                    color: status == OrderStatus.siapDiambil
                        ? const Color(0xFF2E7D32)
                        : (status == OrderStatus.menungguPembayaran
                            ? const Color(0xFFE65100)
                            : AppColors.primaryBrown),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      status == OrderStatus.siapDiambil
                          ? 'Silakan menuju counter & sebutkan ${order.id}'
                          : (status == OrderStatus.menungguPembayaran
                              ? 'Bayar tunai di kasir: ${order.formattedTotalPrice}'
                              : 'Perkiraan siap dalam ~${order.estimatedMinutes} menit'),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: status == OrderStatus.siapDiambil
                            ? const Color(0xFF2E7D32)
                            : (status == OrderStatus.menungguPembayaran
                                ? const Color(0xFFE65100)
                                : AppColors.darkBrown),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 14),

          // Barista Live Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.inputBorderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primaryBrown,
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pesan dari ${order.baristaName}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.baristaNote,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.darkText,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    final isWaitingPayment = order.status == OrderStatus.menungguPembayaran;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: isWaitingPayment
            ? const Color(0xFFFFF8E1)
            : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWaitingPayment
              ? const Color(0xFFFFD54F)
              : const Color(0xFFA5D6A7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 3.5,
            backgroundColor: isWaitingPayment
                ? const Color(0xFFF57C00)
                : const Color(0xFF388E3C),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              isWaitingPayment ? 'MENUNGGU PEMBAYARAN KASIR' : 'LIVE TRACKING',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isWaitingPayment
                    ? const Color(0xFFE65100)
                    : const Color(0xFF2E7D32),
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
