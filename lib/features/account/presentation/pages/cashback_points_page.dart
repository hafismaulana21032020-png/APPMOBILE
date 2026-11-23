import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../cart/domain/services/cart_service.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../../home/presentation/widgets/home_nav_helper.dart';
import '../../domain/services/user_service.dart';

class CashbackPointsPage extends StatefulWidget {
  const CashbackPointsPage({super.key});

  @override
  State<CashbackPointsPage> createState() => _CashbackPointsPageState();
}

class _CashbackPointsPageState extends State<CashbackPointsPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _logs = [];
  String _selectedFilter = 'Semua'; // 'Semua' | 'Masuk' | 'Terpakai'

  @override
  void initState() {
    super.initState();
    _fetchPointsData();
  }

  Future<void> _fetchPointsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await ApiService.instance.getMyPoints();
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        final balance = data['balance'] as int? ?? 0;
        UserService.instance.setPoints(balance);

        final rawLogs = data['logs'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            _logs = rawLogs.map((e) => Map<String, dynamic>.from(e)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching points data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredLogs {
    if (_selectedFilter == 'Masuk') {
      return _logs.where((l) {
        final type = l['type']?.toString().toUpperCase();
        final points = (l['points'] as num?)?.toInt() ?? 0;
        return type == 'EARN' || (type == 'VOID_REFUND' && points > 0);
      }).toList();
    } else if (_selectedFilter == 'Terpakai') {
      return _logs.where((l) {
        final type = l['type']?.toString().toUpperCase();
        final points = (l['points'] as num?)?.toInt() ?? 0;
        return type == 'REDEEM' || (type == 'VOID_REFUND' && points < 0);
      }).toList();
    }
    return _logs;
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'Baru saja';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    final local = dt.toLocal();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = local.day.toString().padLeft(2, '0');
    final month = months[(local.month - 1) % 12];
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([UserService.instance, CartService.instance]),
      builder: (context, _) {
        final user = UserService.instance;
        final cartCount = CartService.instance.totalItemCount;
        final equivalentRp = (user.points ~/ 100) * 1000;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // ══════════════════════ HEADER ══════════════════════
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
                          'Cashback & Poin',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBrown),
                        tooltip: 'Muat ulang data',
                        onPressed: _fetchPointsData,
                      ),
                    ],
                  ),
                ),

                // ══════════════════════ SCROLLABLE CONTENT ══════════════════════
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchPointsData,
                    color: AppColors.primaryBrown,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),

                          // ── 1. HERO CARD SALDO POIN ──
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      user.name.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withOpacity(0.9),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.promoBadgeColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        user.memberBadge,
                                        style: const TextStyle(
                                          color: Color(0xFF4A3000),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Saldo Poin Kamu',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              AppFormatters.formatThousands(user.points),
                                              style: const TextStyle(
                                                fontSize: 34,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'poin',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white.withOpacity(0.85),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Setara potongan hingga ${AppFormatters.formatRupiah(equivalentRp)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFFFE082),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Ikon Koin Emas
                                    Container(
                                      width: 54,
                                      height: 54,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0x66FFB300),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.stars_rounded,
                                          color: Color(0xFF5D4037),
                                          size: 34,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                // Badge Kecil: Bisa Dipakai Saat Checkout
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.25),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: Color(0xFFFFE082),
                                        size: 15,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Bisa dipakai saat Checkout',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ── 2. KARTU RINGKAS CARA KERJA ──
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.inputBorderColor,
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
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
                                      Icons.info_outline_rounded,
                                      size: 18,
                                      color: AppColors.primaryBrown,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Cara Kerja Poin BreakFree',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1, thickness: 1, color: Color(0xFFF0EBE5)),
                                const SizedBox(height: 12),
                                _buildRuleRow(
                                  icon: Icons.card_giftcard_rounded,
                                  iconColor: const Color(0xFF2E7D32),
                                  bgColor: const Color(0xFFE8F5E9),
                                  text: 'Rp 1.000 belanja = 5 poin (Cashback 5%)',
                                ),
                                const SizedBox(height: 10),
                                _buildRuleRow(
                                  icon: Icons.currency_exchange_rounded,
                                  iconColor: const Color(0xFFE65100),
                                  bgColor: const Color(0xFFFFF3E0),
                                  text: '100 poin = potongan Rp 1.000',
                                ),
                                const SizedBox(height: 10),
                                _buildRuleRow(
                                  icon: Icons.shopping_bag_outlined,
                                  iconColor: AppColors.primaryBrown,
                                  bgColor: AppColors.cardBgColor,
                                  text: 'Berlaku kelipatan 100 poin, maks. 25% saat Checkout',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── 3. RIWAYAT POIN (MUTASI) ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Riwayat Poin',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              if (_isLoading)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBrown),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Filter Tabs (Semua, Masuk, Terpakai)
                          Row(
                            children: [
                              _buildFilterChip('Semua'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Masuk'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Terpakai'),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Mutation List / Empty State
                          if (_isLoading && _logs.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBrown),
                                ),
                              ),
                            )
                          else if (_filteredLogs.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.inputBorderColor,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF5F0EB),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.receipt_long_outlined,
                                      size: 34,
                                      color: AppColors.primaryBrown,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Belum Ada Riwayat Poin',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Lakukan transaksi pemesanan menu untuk mengumpulkan cashback 5% poin BreakFree!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondaryText,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredLogs.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final log = _filteredLogs[index];
                                final type = log['type']?.toString().toUpperCase() ?? 'EARN';
                                final rawPoints = (log['points'] as num?)?.toInt() ?? 0;
                                final isEarn = type == 'EARN' || (type == 'VOID_REFUND' && rawPoints > 0);
                                final pointsValue = rawPoints.abs();
                                final desc = log['description']?.toString() ?? 'Mutasi Poin';
                                final dateStr = _formatDate(log['createdAt']?.toString() ?? log['created_at']?.toString());

                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.inputBorderColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: isEarn ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          isEarn ? Icons.south_west_rounded : Icons.north_east_rounded,
                                          color: isEarn ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              desc,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.darkText,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              dateStr,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${isEarn ? '+' : '-'}$pointsValue poin',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isEarn ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // ══════════════════════ 4. TOMBOL CTA BAWAH ══════════════════════
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.inputBorderColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (CartService.instance.items.isNotEmpty) {
                          Navigator.pushNamed(context, AppRoutes.cart);
                        } else {
                          Navigator.pushNamed(context, AppRoutes.menu);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrown,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CartService.instance.items.isNotEmpty
                                ? Icons.shopping_bag_outlined
                                : Icons.restaurant_menu_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            CartService.instance.items.isNotEmpty
                                ? 'Lihat Keranjang & Pakai Poin (${CartService.instance.totalItemCount})'
                                : 'Pesan Menu & Pakai Poin',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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
            orderBadgeCount: cartCount,
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

  Widget _buildRuleRow({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBrown : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBrown : AppColors.inputBorderColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}
