import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/coffee_menu_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/menu_page.dart';
import '../../features/account/presentation/pages/account_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/home/presentation/pages/non_coffee_menu_page.dart';
import '../../features/home/presentation/pages/food_menu_page.dart';
import '../../features/home/presentation/pages/snack_menu_page.dart';
import '../../features/account/presentation/pages/profile_page.dart';
import '../../features/cart/presentation/pages/payment_success_page.dart';
import '../../features/account/presentation/pages/help_page.dart';
import '../../features/account/presentation/pages/settings_page.dart';
import '../../features/account/presentation/pages/notifications_page.dart';
import '../../features/account/presentation/pages/cashback_points_page.dart';
import '../../features/account/presentation/pages/favorites_page.dart';
import '../../features/home/presentation/pages/ai_chat_page.dart';
import '../../features/order/presentation/pages/order_tracking_page.dart';
import 'app_routes.dart';

/// Custom PageRouteBuilder dengan transisi slide halus (smooth slide transition)
class SmoothSlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SmoothSlidePageRoute({
    required this.page,
    super.settings,
    Duration duration = const Duration(milliseconds: 320),
    Duration reverseDuration = const Duration(milliseconds: 280),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            // Slide masuk dari kanan secara halus
            final slideIn = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(curvedAnimation);

            // Efek parallax halus untuk halaman sebelumnya
            final secondarySlideOut = Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.25, 0.0),
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
            );

            // Transisi fade lembut bersamaan dengan slide
            final fadeIn = Tween<double>(
              begin: 0.1,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
              ),
            );

            return SlideTransition(
              position: secondarySlideOut,
              child: SlideTransition(
                position: slideIn,
                child: FadeTransition(
                  opacity: fadeIn,
                  child: child,
                ),
              ),
            );
          },
        );
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.initial:
      case AppRoutes.login:
        return SmoothSlidePageRoute(
          page: const LoginPage(),
          settings: settings,
        );
      case AppRoutes.register:
        return SmoothSlidePageRoute(
          page: const RegisterPage(),
          settings: settings,
        );
      case AppRoutes.forgotPassword:
        final args = settings.arguments;
        final initialEmail = args is String
            ? args
            : (args is Map ? args['email']?.toString() : null);
        return SmoothSlidePageRoute(
          page: ForgotPasswordPage(initialEmail: initialEmail),
          settings: settings,
        );
      case AppRoutes.home:
        return SmoothSlidePageRoute(
          page: const HomePage(),
          settings: settings,
        );
      case AppRoutes.menu:
        return SmoothSlidePageRoute(
          page: const MenuPage(),
          settings: settings,
        );
      case AppRoutes.coffeeMenu:
        return SmoothSlidePageRoute(
          page: const CoffeeMenuPage(),
          settings: settings,
        );
      case AppRoutes.account:
        return SmoothSlidePageRoute(
          page: const AccountPage(),
          settings: settings,
        );
      case AppRoutes.cart:
        return SmoothSlidePageRoute(
          page: const CartPage(),
          settings: settings,
        );
      case AppRoutes.nonCoffee:
        return SmoothSlidePageRoute(
          page: const NonCoffeeMenuPage(),
          settings: settings,
        );
      case AppRoutes.foodMenu:
        return SmoothSlidePageRoute(
          page: const FoodMenuPage(),
          settings: settings,
        );
      case AppRoutes.snackMenu:
        return SmoothSlidePageRoute(
          page: const SnackMenuPage(),
          settings: settings,
        );
      case AppRoutes.profile:
        return SmoothSlidePageRoute(
          page: const ProfilePage(),
          settings: settings,
        );
      case AppRoutes.paymentSuccess:
        return SmoothSlidePageRoute(
          page: const PaymentSuccessPage(),
          settings: settings,
        );
      case AppRoutes.help:
        return SmoothSlidePageRoute(
          page: const HelpPage(),
          settings: settings,
        );
      case AppRoutes.settings:
        return SmoothSlidePageRoute(
          page: const SettingsPage(),
          settings: settings,
        );
      case AppRoutes.notifications:
        return SmoothSlidePageRoute(
          page: const NotificationsPage(),
          settings: settings,
        );
      case AppRoutes.cashbackPoints:
        return SmoothSlidePageRoute(
          page: const CashbackPointsPage(),
          settings: settings,
        );
      case AppRoutes.aiChat:
        return SmoothSlidePageRoute(
          page: const AiChatPage(),
          settings: settings,
        );
      case AppRoutes.orderTracking:
        final initialTab = (settings.arguments is int)
            ? settings.arguments as int
            : 0;
        return SmoothSlidePageRoute(
          page: OrderTrackingPage(initialTabIndex: initialTab),
          settings: settings,
        );
      case AppRoutes.favorites:
        return SmoothSlidePageRoute(
          page: const FavoritesPage(),
          settings: settings,
        );
      default:
        return SmoothSlidePageRoute(
          page: Scaffold(
            body: Center(
              child: Text('Halaman tidak ditemukan: ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
