import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/coffee_menu_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/account/presentation/pages/account_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/home/presentation/pages/non_coffee_menu_page.dart';
import '../../features/home/presentation/pages/food_menu_page.dart';
import '../../features/home/presentation/pages/snack_menu_page.dart';
import '../../features/account/presentation/pages/profile_page.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.initial:
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordPage(),
          settings: settings,
        );
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case AppRoutes.coffeeMenu:
        return MaterialPageRoute(
          builder: (_) => const CoffeeMenuPage(),
          settings: settings,
        );
      case AppRoutes.account:
        return MaterialPageRoute(
          builder: (_) => const AccountPage(),
          settings: settings,
        );
      case AppRoutes.cart:
        return MaterialPageRoute(
          builder: (_) => const CartPage(),
          settings: settings,
        );
      case AppRoutes.nonCoffee:
        return MaterialPageRoute(
          builder: (_) => const NonCoffeeMenuPage(),
          settings: settings,
        );
      case AppRoutes.foodMenu:
        return MaterialPageRoute(
          builder: (_) => const FoodMenuPage(),
          settings: settings,
        );
      case AppRoutes.snackMenu:
        return MaterialPageRoute(
          builder: (_) => const SnackMenuPage(),
          settings: settings,
        );
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Halaman tidak ditemukan: ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
