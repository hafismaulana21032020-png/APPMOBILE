import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cart/domain/services/cart_service.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../../home/presentation/widgets/home_nav_helper.dart';
import '../../domain/services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = [
    'Semua',
    'Pesanan',
    'Poin & member',
    'Promo',
  ];

  @override
  void initState() {
    super.initState();
    NotificationService.instance.fetchNotifications();
  }

  IconData _iconForCategory(String category, String title) {
    final lower = title.toLowerCase();
    if (lower.contains('batal')) return Icons.cancel_outlined;
    if (category == 'Pesanan') return Icons.shopping_bag_outlined;
    if (category == 'Poin & member') return Icons.star_outline_rounded;
    if (category == 'Promo') return Icons.discount_outlined;
    return Icons.notifications_none_rounded;
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        NotificationService.instance,
        CartService.instance,
      ]),
      builder: (context, _) {
        final service = NotificationService.instance;
        final unread = service.unreadCount;
        final isLoading = service.isLoading;

        final filtered = service.items.where((n) {
          if (_selectedCategory == 'Semua') return true;
          return n.category == _selectedCategory;
        }).toList();

        final now = DateTime.now();
        final todayItems = filtered.where((n) => _isSameDay(n.createdAt, now)).toList();
        final earlierItems = filtered.where((n) => !_isSameDay(n.createdAt, now)).toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.inputBorderColor,
                            width: 1.0,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: AppColors.darkText,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Notifikasi',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (unread > 0)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFE7DE),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBrown,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => NotificationService.instance.fetchNotifications(),
                    color: AppColors.primaryBrown,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryBrown,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        unread > 0
                                            ? '$unread notifikasi belum dibaca'
                                            : 'Semua notifikasi sudah dibaca',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (unread > 0) ...[
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    NotificationService.instance.markAllAsRead();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Semua notifikasi ditandai telah dibaca'),
                                        backgroundColor: AppColors.primaryBrown,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Tandai semua dibaca',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Category Pills
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _categories.map((category) {
                                final isSelected = _selectedCategory == category;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = category;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primaryBrown
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primaryBrown
                                              : AppColors.inputBorderColor,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.darkText,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 22),

                          if (isLoading && filtered.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 48),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryBrown,
                                ),
                              ),
                            )
                          else ...[
                            if (todayItems.isNotEmpty) ...[
                              const Text(
                                'Hari ini',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...todayItems.map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _NotificationCard(
                                      item: item,
                                      timeLabel: _formatTime(item.createdAt),
                                      icon: _iconForCategory(item.category, item.title),
                                      onTap: () {
                                        NotificationService.instance.markAsRead(item.id);
                                      },
                                      actionText: item.category == 'Pesanan'
                                          ? 'Lihat pesanan'
                                          : (item.category == 'Promo' ? 'Pakai di Keranjang' : null),
                                      onActionTap: () {
                                        NotificationService.instance.markAsRead(item.id);
                                        if (item.category == 'Pesanan') {
                                          Navigator.pushNamed(context, AppRoutes.orderTracking);
                                        } else if (item.category == 'Promo') {
                                          Navigator.pushNamed(context, AppRoutes.cart);
                                        }
                                      },
                                    ),
                                  )),
                              const SizedBox(height: 10),
                            ],

                            if (earlierItems.isNotEmpty) ...[
                              const Text(
                                'Sebelumnya',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...earlierItems.map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _NotificationCard(
                                      item: item,
                                      timeLabel:
                                          '${item.createdAt.day}/${item.createdAt.month} • ${_formatTime(item.createdAt)}',
                                      icon: _iconForCategory(item.category, item.title),
                                      onTap: () {
                                        NotificationService.instance.markAsRead(item.id);
                                      },
                                    ),
                                  )),
                            ],

                            if (todayItems.isEmpty && earlierItems.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 48),
                                child: Center(
                                  child: Text(
                                    'Belum ada notifikasi di kategori ini',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                              ),
                          ],

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: HomeBottomNavBar(
            currentIndex: 3,
            orderBadgeCount: CartService.instance.totalItemCount,
            onTap: (index) => handleSecondaryBottomNavTap(
              context,
              index,
              currentIndex: 3,
            ),
          ),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final RealNotificationItem item;
  final String timeLabel;
  final IconData icon;
  final VoidCallback onTap;
  final String? actionText;
  final VoidCallback? onActionTap;

  const _NotificationCard({
    required this.item,
    required this.timeLabel,
    required this.icon,
    required this.onTap,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.inputBorderColor,
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5EFE6),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: AppColors.darkBrown),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.category,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        if (item.isUnread) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBrown,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                    ),
                    if (actionText != null) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: onActionTap,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              actionText!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBrown,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: AppColors.primaryBrown,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
