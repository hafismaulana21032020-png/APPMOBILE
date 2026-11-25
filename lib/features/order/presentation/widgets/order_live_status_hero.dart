import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../cart/presentation/widgets/midtrans_payment_sheet.dart';
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
              gradient: LinearGradient(
                colors: order.isCancelled
                    ? const [Color(0xFFFFF5F5), Color(0xFFFFEBEE)]
                    : const [AppColors.cardBgColor, Color(0xFFEFE7DB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: order.isCancelled
                    ? const Color(0xFFFFCDD2)
                    : AppColors.primaryBrown.withAlpha(40),
              ),
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
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: order.isCancelled
                              ? const Color(0xFFC62828)
                              : AppColors.darkBrown,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.storefront_rounded,
                            size: 14,
                            color: order.isCancelled
                                ? const Color(0xFFC62828)
                                : AppColors.primaryBrown,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${order.counterName} • ${order.displayOrderType}',
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
                    color: order.isCancelled
                        ? const Color(0xFFC62828)
                        : AppColors.primaryBrown,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (order.isCancelled
                                ? const Color(0xFFC62828)
                                : AppColors.primaryBrown)
                            .withAlpha(60),
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
            status == OrderStatus.dibatalkan
                ? 'Pesanan Dibatalkan oleh Kasir'
                : status.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: order.isCancelled
                  ? const Color(0xFFC62828)
                  : AppColors.darkText,
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

          if (order.isCancelled) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF9A9A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 16,
                        color: Color(0xFFC62828),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Alasan Pembatalan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB71C1C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (order.cancelReason != null &&
                            order.cancelReason!.trim().isNotEmpty)
                        ? order.cancelReason!
                        : 'Pesanan dibatalkan oleh kasir BreakFree.',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7F1D1D),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Jika transaksi memakai Poin Member atau sudah dibayar, pengembalian poin/dana diproses otomatis.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF991B1B),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (status != OrderStatus.selesai)
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
                              ? (order.hasPendingMidtrans
                                  ? 'Selesaikan pembayaran Midtrans: ${order.formattedTotalPrice}'
                                  : 'Bayar tunai di kasir: ${order.formattedTotalPrice}')
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

          if (order.hasPendingMidtrans) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {
                  MidtransPaymentSheet.show(
                    context,
                    order: order,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.payment_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'Lanjutkan Pembayaran Midtrans',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Cashier / Barista Live Info
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
                        'Dilayani oleh: ${order.cashierDisplayName}',
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
    final isCancelled = order.isCancelled;
    final isWaitingPayment = order.status == OrderStatus.menungguPembayaran;
    final bgColor = isCancelled
        ? const Color(0xFFFFEBEE)
        : (isWaitingPayment
            ? const Color(0xFFFFF8E1)
            : const Color(0xFFE8F5E9));
    final borderColor = isCancelled
        ? const Color(0xFFEF9A9A)
        : (isWaitingPayment
            ? const Color(0xFFFFD54F)
            : const Color(0xFFA5D6A7));
    final dotColor = isCancelled
        ? const Color(0xFFC62828)
        : (isWaitingPayment
            ? const Color(0xFFF57C00)
            : const Color(0xFF388E3C));
    final textColor = isCancelled
        ? const Color(0xFFC62828)
        : (isWaitingPayment
            ? const Color(0xFFE65100)
            : const Color(0xFF2E7D32));
    final label = isCancelled
        ? 'PESANAN DIBATALKAN'
        : (isWaitingPayment
            ? (order.hasPendingMidtrans
                ? 'MENUNGGU BAYAR MIDTRANS'
                : 'MENUNGGU PEMBAYARAN KASIR')
            : 'LIVE TRACKING');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 3.5,
            backgroundColor: dotColor,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
