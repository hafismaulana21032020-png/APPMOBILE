import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../domain/models/order_model.dart';
import '../../domain/services/order_service.dart';
import '../widgets/order_items_card.dart';
import '../widgets/order_live_status_hero.dart';
import '../widgets/order_timeline_stepper.dart';

/// Full live tracking screen for BreakFree customer orders.
class OrderTrackingPage extends StatefulWidget {
  final int initialTabIndex;

  const OrderTrackingPage({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  late int _selectedTab;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;

    // Sinkronisasi status pesanan & riwayat nyata dari backend MySQL
    OrderService.instance.syncActiveOrderFromBackend();
    OrderService.instance.loadHistoryFromBackend();

    // Auto-polling status pesanan & Midtrans setiap 3 detik
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;
      final active = OrderService.instance.activeOrder;
      if (active != null && active.hasPendingMidtrans) {
        await OrderService.instance.checkMidtransStatus(active.id);
      } else {
        await OrderService.instance.syncActiveOrderFromBackend();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _onBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    }
  }

  void _showOrderDetailsDialog(OrderModel order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.inputBorderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Pesanan ${order.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
              Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (order.isCancelled) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEF9A9A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.cancel_rounded,
                                  size: 18,
                                  color: Color(0xFFC62828),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Pesanan Dibatalkan oleh Kasir',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFB71C1C),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              (order.cancelReason != null &&
                                      order.cancelReason!.isNotEmpty)
                                  ? 'Alasan: ${order.cancelReason}'
                                  : 'Pesanan dibatalkan oleh kasir BreakFree.',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF7F1D1D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    OrderItemsCard(order: order),
                    const SizedBox(height: 12),
                    OrderTimelineStepper(
                      currentStatus: order.status,
                      statusTimes: order.statusTimes,
                      paymentMethod: order.paymentMethod,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService.instance;

    return AnimatedBuilder(
      animation: orderService,
      builder: (context, _) {
        final activeOrder = orderService.activeOrder;
        final history = orderService.orderHistory;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.darkBrown,
                size: 20,
              ),
              onPressed: _onBack,
            ),
            title: const Text(
              'Lacak Pesanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBrown,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: 'Sinkronkan Status',
                icon: const Icon(
                  Icons.sync_rounded,
                  color: AppColors.primaryBrown,
                  size: 20,
                ),
                onPressed: () {
                  OrderService.instance.syncActiveOrderFromBackend();
                  OrderService.instance.loadHistoryFromBackend();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Menyinkronkan status pesanan dari kasir Web POS...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Tanya Barista AI',
                icon: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primaryBrown,
                  size: 20,
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.aiChat),
              ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.inputBorderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabPill(
                          index: 0,
                          icon: Icons.delivery_dining_rounded,
                          label: 'Pesanan Aktif',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildTabPill(
                          index: 1,
                          icon: Icons.history_rounded,
                          label: 'Riwayat (${history.length})',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: _selectedTab == 0
                ? _buildActiveOrderView(activeOrder)
                : _buildHistoryView(history),
          ),
        );
      },
    );
  }

  Widget _buildTabPill({
    required int index,
    required IconData icon,
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
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBrown : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.secondaryText,
            ),
            const SizedBox(width: 6),
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

  Widget _buildActiveOrderView(OrderModel? activeOrder) {
    if (activeOrder == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.cardBgColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 34,
                  color: AppColors.primaryBrown,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Belum Ada Pesanan Aktif',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kamu belum memesan menu hari ini. Pilih kopi dan makanan favoritmu untuk mulai melacak pesanan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.menu),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lihat Menu Kopi & Makanan',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => OrderService.instance.syncActiveOrderFromBackend(),
      color: AppColors.primaryBrown,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Live Hero Status Card
          OrderLiveStatusHero(order: activeOrder),
          const SizedBox(height: 16),

          // 2. Timeline Stepper
          OrderTimelineStepper(
            currentStatus: activeOrder.status,
            statusTimes: activeOrder.statusTimes,
            paymentMethod: activeOrder.paymentMethod,
          ),
          const SizedBox(height: 16),

          // 3. Items and Payment Summary
          OrderItemsCard(order: activeOrder),
          const SizedBox(height: 20),

          // 4. Action Buttons
          if (activeOrder.isCancelled) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  OrderService.instance.clearActiveOrder();
                  OrderService.instance.loadHistoryFromBackend();
                  setState(() {
                    _selectedTab = 1;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text(
                  'Tutup & Simpan ke Riwayat',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.aiChat),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text(
                  'Tanya Barista AI tentang Pesanan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryBrown),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Kembali ke Menu Utama',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBrown,
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildHistoryView(List<OrderModel> history) {
    if (history.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => OrderService.instance.loadHistoryFromBackend(),
        color: AppColors.primaryBrown,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Center(
              child: Text(
                'Belum ada riwayat transaksi.',
                style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => OrderService.instance.loadHistoryFromBackend(),
      color: AppColors.primaryBrown,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        itemCount: history.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final order = history[index];
          final localDt = order.createdAt.toLocal();
          final hh = localDt.hour.toString().padLeft(2, '0');
          final mm = localDt.minute.toString().padLeft(2, '0');
          final formattedDate =
              '${localDt.day}/${localDt.month}/${localDt.year} • $hh:$mm WIB';

          final isCancelled = order.status == OrderStatus.dibatalkan;
          final isDone = order.status == OrderStatus.selesai;
          final badgeBg = isCancelled
              ? const Color(0xFFFFEBEE)
              : (isDone ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1));
          final badgeTextColor = isCancelled
              ? const Color(0xFFC62828)
              : (isDone ? const Color(0xFF2E7D32) : const Color(0xFFE65100));

          return InkWell(
            onTap: () => _showOrderDetailsDialog(order),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCancelled
                      ? const Color(0xFFFFCDD2)
                      : AppColors.inputBorderColor,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCancelled
                          ? const Color(0xFFFFEBEE)
                          : AppColors.cardBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        isCancelled
                            ? Icons.cancel_rounded
                            : Icons.receipt_rounded,
                        color: isCancelled
                            ? const Color(0xFFC62828)
                            : AppColors.primaryBrown,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                order.id,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                order.status.badgeText,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: badgeTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$formattedDate • ${order.totalItemCount} Item • ${order.paymentMethod}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppFormatters.formatRupiah(order.totalPrice),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isCancelled
                                    ? const Color(0xFFC62828)
                                    : AppColors.primaryBrown,
                                decoration: isCancelled
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            Text(
                              order.orderType == 'TAKEAWAY' ? 'Takeaway' : 'Dine-in',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        if (isCancelled &&
                            order.cancelReason != null &&
                            order.cancelReason!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Alasan: ${order.cancelReason}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFFC62828),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.secondaryText,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
