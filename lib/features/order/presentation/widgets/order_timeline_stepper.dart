import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/order_model.dart';

/// Stepper timeline widget for live order tracking.
class OrderTimelineStepper extends StatelessWidget {
  final OrderStatus currentStatus;
  final Map<OrderStatus, DateTime> statusTimes;
  final String? paymentMethod;

  const OrderTimelineStepper({
    super.key,
    required this.currentStatus,
    required this.statusTimes,
    this.paymentMethod,
  });

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  List<OrderStatus> get _displaySteps {
    final isCash = (paymentMethod?.toLowerCase().contains('cash') ?? false) ||
        (paymentMethod?.toLowerCase().contains('tunai') ?? false) ||
        currentStatus == OrderStatus.menungguPembayaran;

    if (isCash) {
      return const [
        OrderStatus.menungguPembayaran,
        OrderStatus.diproses,
        OrderStatus.siapDiambil,
        OrderStatus.selesai,
      ];
    } else {
      return const [
        OrderStatus.diterima,
        OrderStatus.diproses,
        OrderStatus.siapDiambil,
        OrderStatus.selesai,
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = _displaySteps;
    final currentIndex = steps.indexOf(currentStatus);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inputBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                size: 20,
                color: AppColors.primaryBrown,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tahapan Pesanan',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isCompleted = currentIndex > index ||
                (currentIndex == -1 && step.stepIndex < currentStatus.stepIndex);
            final isCurrent = step == currentStatus;
            final isLast = index == steps.length - 1;
            final time = statusTimes[step];

            return _buildStepRow(
              step: step,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLast: isLast,
              timeString: time != null ? _formatTime(time) : null,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required OrderStatus step,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
    String? timeString,
  }) {
    Color indicatorBg;
    Color iconColor;
    Widget iconWidget;

    if (isCompleted) {
      indicatorBg = const Color(0xFF4CAF50);
      iconColor = Colors.white;
      iconWidget = const Icon(Icons.check, size: 14, color: Colors.white);
    } else if (isCurrent) {
      indicatorBg = AppColors.primaryBrown;
      iconColor = Colors.white;
      iconWidget = Icon(step.icon, size: 14, color: iconColor);
    } else {
      indicatorBg = const Color(0xFFEEEEEE);
      iconColor = AppColors.secondaryText;
      iconWidget = Icon(step.icon, size: 14, color: iconColor);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Indicator circle & connecting line
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: indicatorBg,
                  shape: BoxShape.circle,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.primaryBrown.withAlpha(90),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(child: iconWidget),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isCompleted
                        ? const Color(0xFF4CAF50)
                        : AppColors.inputBorderColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Right: Title, subtitle, and timestamp
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrent || isCompleted
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isCurrent || isCompleted
                                ? AppColors.darkText
                                : AppColors.secondaryText,
                          ),
                        ),
                      ),
                      if (timeString != null)
                        Text(
                          timeString,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isCurrent
                                ? AppColors.primaryBrown
                                : AppColors.secondaryText,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    step.subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isCurrent
                          ? AppColors.darkBrown
                          : AppColors.secondaryText,
                      height: 1.3,
                    ),
                  ),
                  if (isCurrent && step == OrderStatus.siapDiambil) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFFEEBA)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.campaign_rounded,
                            size: 14,
                            color: Color(0xFF856404),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Panggilan antrean: Silakan ambil di Counter Bar!',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF856404),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
