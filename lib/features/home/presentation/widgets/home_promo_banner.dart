import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';

class PromoSlideData {
  final String badgeText;
  final String title;
  final String subtitle;
  final String imagePath;

  const PromoSlideData({
    required this.badgeText,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}

class HomePromoBanner extends StatefulWidget {
  final String? badgeText;
  final String? title;
  final String? subtitle;

  const HomePromoBanner({
    super.key,
    this.badgeText,
    this.title,
    this.subtitle,
  });

  @override
  State<HomePromoBanner> createState() => _HomePromoBannerState();
}

class _HomePromoBannerState extends State<HomePromoBanner> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  late final List<PromoSlideData> _slides;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _slides = [
      PromoSlideData(
        badgeText: widget.badgeText ?? 'PROMO MAHASISWA',
        title: widget.title ?? 'Diskon 20% Hari Ini!',
        subtitle: widget.subtitle ?? 'Kopi favoritmu, selalu dekat denganmu.',
        imagePath: AppAssets.homePromoBanner,
      ),
      const PromoSlideData(
        badgeText: 'PAKET HEMAT',
        title: 'Beli 2 Kopi Gratis 1 Snack',
        subtitle: 'Teman nugas paling pas di BreakFree Malang.',
        imagePath: AppAssets.coffeeBanner,
      ),
      const PromoSlideData(
        badgeText: 'SPESIAL MEMBER',
        title: 'Double Poin Tiap Hari Jumat',
        subtitle: 'Kumpulkan poin lebih cepat untuk kopi gratis.',
        imagePath: AppAssets.breakfreeArenLatte,
      ),
    ];

    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 158,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: Stack(
          children: [
            // PageView Slider dengan transisi smooth
            PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image dengan framing dan alignment yang pas agar logo tidak terpotong
                    Image.asset(
                      slide.imagePath,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.primaryBrown,
                        child: const Center(
                          child:
                              Icon(Icons.coffee, size: 48, color: Colors.white),
                        ),
                      ),
                    ),

                    // Gradient Overlay lembut agar logo & teks terbaca jernih
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.70),
                          ],
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Promo Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.promoBadgeColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              slide.badgeText,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkBrown,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          // Texts
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slide.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                slide.subtitle,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            // Smooth Animated Dots Indicator
            Positioned(
              bottom: 12,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_slides.length, (index) {
                  final isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.promoBadgeColor
                          : Colors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
