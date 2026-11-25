import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../order/domain/models/order_model.dart';
import '../../../order/domain/services/order_service.dart';

class HomeActiveOrderCard extends StatelessWidget {
  const HomeActiveOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: OrderService.instance,
      builder: (context, _) {
        final order = OrderService.instance.activeOrder;
        if (order == null || order.status == OrderStatus.selesai) {
          return const SizedBox.shrink();
        }

        final isCancelled = order.isCancelled;
        final bgColor = isCancelled ? const Color(0xFFFFF5F5) : const Color(0xFFF1F8E9);
        final borderColor = isCancelled ? const Color(0xFFFFCDD2) : const Color(0xFFC8E6C9);
        final accentColor = isCancelled ? const Color(0xFFC62828) : const Color(0xFF2E7D32);
        final titleColor = isCancelled ? const Color(0xFFB71C1C) : const Color(0xFF1B5E20);
        final subtitleColor = isCancelled ? const Color(0xFFC62828) : const Color(0xFF33691E);
        final pillBg = isCancelled ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9);
        final pillBorder = isCancelled ? const Color(0xFFEF9A9A) : const Color(0xFFA5D6A7);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.orderTracking);
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    // Icon status aktif
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isCancelled
                            ? Icons.cancel_rounded
                            : (order.status == OrderStatus.siapDiambil
                                ? Icons.notifications_active_rounded
                                : Icons.coffee_maker_rounded),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Detail Pesanan
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Antrean ${order.queueNumber}',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: pillBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: pillBorder,
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  order.status.badgeText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isCancelled
                                ? 'Pesanan Dibatalkan • Ketuk untuk detail'
                                : '${order.status.title} • Ketuk untuk lacak live',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: subtitleColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: accentColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
