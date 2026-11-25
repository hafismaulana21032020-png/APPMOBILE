import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';

class RealNotificationItem {
  final String id;
  final String category; // 'Pesanan', 'Poin & member', 'Promo'
  final String title;
  final String subtitle;
  final String? orderId;
  final DateTime createdAt;
  bool isUnread;

  RealNotificationItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    this.orderId,
    required this.createdAt,
    this.isUnread = false,
  });

  factory RealNotificationItem.fromJson(Map<String, dynamic> json) {
    return RealNotificationItem(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Pesanan',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      orderId: json['orderId']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
      isUnread: json['isUnread'] == true,
    );
  }
}

/// Service notifikasi real-time yang bersumber dari database MySQL
/// (Pesanan aktif/batal, mutasi poin point_logs, dan promo aktif discounts).
class NotificationService extends ChangeNotifier {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final Set<String> _readIds = {};
  List<RealNotificationItem> _items = [];
  bool _isLoading = false;

  List<RealNotificationItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  int get unreadCount => _items.where((n) => n.isUnread && !_readIds.contains(n.id)).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    await Future<void>.delayed(Duration.zero);
    if (_isLoading) {
      notifyListeners();
    }

    try {
      final res = await ApiService.instance.getNotifications();
      if (res['success'] == true && res['notifications'] is List) {
        final rawList = res['notifications'] as List;
        _items = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) {
              final item = RealNotificationItem.fromJson(e);
              if (_readIds.contains(item.id)) {
                item.isUnread = false;
              }
              return item;
            })
            .toList();
      }
    } catch (e) {
      debugPrint('NotificationService fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void markAsRead(String id) {
    _readIds.add(id);
    for (final item in _items) {
      if (item.id == id) {
        item.isUnread = false;
      }
    }
    notifyListeners();
  }

  void markAllAsRead() {
    for (final item in _items) {
      _readIds.add(item.id);
      item.isUnread = false;
    }
    notifyListeners();
  }

  void clear() {
    _items = [];
    _readIds.clear();
    notifyListeners();
  }
}
