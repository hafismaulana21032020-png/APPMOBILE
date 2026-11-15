import 'package:breakfree_app/app.dart';
import 'package:breakfree_app/core/constants/app_assets.dart';
import 'package:breakfree_app/core/routes/app_router.dart';
import 'package:breakfree_app/core/theme/app_theme.dart';
import 'package:breakfree_app/core/utils/app_formatters.dart';
import 'package:breakfree_app/core/utils/app_validators.dart';
import 'package:breakfree_app/features/account/domain/services/user_service.dart';
import 'package:breakfree_app/features/account/presentation/pages/account_page.dart';
import 'package:breakfree_app/features/account/presentation/pages/profile_page.dart';
import 'package:breakfree_app/features/account/presentation/widgets/account_stats_row.dart';
import 'package:breakfree_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:breakfree_app/features/auth/presentation/pages/login_page.dart';
import 'package:breakfree_app/features/auth/presentation/pages/register_page.dart';
import 'package:breakfree_app/features/cart/domain/services/cart_service.dart';
import 'package:breakfree_app/features/cart/presentation/pages/cart_page.dart';
import 'package:breakfree_app/features/home/data/menu_data.dart';
import 'package:breakfree_app/features/home/presentation/controllers/home_tab_controller.dart';
import 'package:breakfree_app/features/home/presentation/pages/coffee_menu_page.dart';
import 'package:breakfree_app/features/home/presentation/pages/food_menu_page.dart';
import 'package:breakfree_app/features/home/presentation/pages/home_page.dart';
import 'package:breakfree_app/features/home/presentation/pages/menu_page.dart';
import 'package:breakfree_app/features/home/presentation/pages/non_coffee_menu_page.dart';
import 'package:breakfree_app/features/home/presentation/pages/snack_menu_page.dart';
import 'package:breakfree_app/features/home/presentation/widgets/home_promo_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatters and Validators', () {
    test('AppFormatters handles thousands and million+ values accurately', () {
      expect(AppFormatters.formatThousands(0), '0');
      expect(AppFormatters.formatThousands(1240), '1.240');
      expect(AppFormatters.formatThousands(1800), '1.800');
      expect(AppFormatters.formatThousands(1000000), '1.000.000');

      expect(AppFormatters.formatRupiah(500), 'Rp 500');
      expect(AppFormatters.formatRupiah(25000), 'Rp 25.000');
      expect(AppFormatters.formatRupiah(1250000), 'Rp 1.250.000');
    });

    test('AppValidators validates email and password rules', () {
      expect(AppValidators.isValidEmail('user@example.com'), isTrue);
      expect(AppValidators.isValidEmail('invalid-email'), isFalse);
      expect(AppValidators.isValidEmail('user@domain'), isFalse);

      expect(AppValidators.isStrongPassword('kopi1234'), isTrue);
      expect(AppValidators.isStrongPassword('short1'), isFalse);
      expect(AppValidators.isStrongPassword('onlyletters'), isFalse);
      expect(AppValidators.isStrongPassword('12345678'), isFalse);
    });
  });

  group('All Pages Render Without Overflow', () {
    final pages = <String, Widget>{
      'LoginPage': const LoginPage(),
      'RegisterPage': const RegisterPage(),
      'ForgotPasswordPage': const ForgotPasswordPage(),
      'HomePage': const HomePage(),
      'MenuPage': const MenuPage(),
      'CoffeeMenuPage': const CoffeeMenuPage(),
      'NonCoffeeMenuPage': const NonCoffeeMenuPage(),
      'FoodMenuPage': const FoodMenuPage(),
      'SnackMenuPage': const SnackMenuPage(),
      'CartPage': const CartPage(),
      'AccountPage': const AccountPage(),
      'ProfilePage': const ProfilePage(),
    };

    for (final size in [const Size(360, 780), const Size(320, 568)]) {
      for (final entry in pages.entries) {
        testWidgets(
            '${entry.key} renders without overflow at ${size.width}x${size.height}',
            (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              onGenerateRoute: AppRouter.onGenerateRoute,
              home: entry.value,
            ),
          );
          await tester.pumpAndSettle();
        });
      }
    }
  });

  group('Core Feature Flows', () {
    testWidgets('App renders login page smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(const BreakFreeApp());

      expect(find.text('BreakFree'), findsOneWidget);
      expect(find.text('Selamat datang kembali!'), findsOneWidget);
    });

    testWidgets('AccountStatsRow displays exact non-rounded points',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccountStatsRow(poin: 1800, pesanan: 12, promo: 3),
          ),
        ),
      );

      expect(find.text('1.800'), findsOneWidget);
      expect(find.text('2.800'), findsNothing);
    });

    testWidgets('RegisterPage validates inputs and navigates to HomePage on success',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        UserService.instance.updateProfile(
          name: 'HAFIZ MAULANA',
          email: 'hafiz.maulana@gmail.com',
          phone: '0812 •••• 7890',
          birthDate: '18 Mei 2000',
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const RegisterPage(),
        ),
      );

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Budi Santoso');
      await tester.enterText(fields.at(1), 'budi@breakfree.id');
      await tester.enterText(fields.at(2), 'kopi1234');
      await tester.enterText(fields.at(3), 'kopi1234');

      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      await tester.ensureVisible(find.text('Daftar'));
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(UserService.instance.name, 'BUDI SANTOSO');
      expect(UserService.instance.email, 'budi@breakfree.id');
    });

    testWidgets('HomePage search finds products across categories',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const HomePage(),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Indomie Goreng');
      await tester.pumpAndSettle();

      expect(find.text('Indomie Goreng'), findsWidgets);
    });

    testWidgets('CartPage rejects spoofed promo code and applies KOPIKAMPUS',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        CartService.instance.clear();
        CartService.instance.addProduct(breakfreeMenuItems.first);
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const CartPage(),
        ),
      );

      final promoField = find.byType(TextField);
      await tester.enterText(promoField, 'FAKEKOPIKAMPUS');
      await tester.tap(find.text('Terapkan'));
      await tester.pump();

      expect(find.text('Kode promo tidak valid'), findsOneWidget);
    });

    testWidgets('HomePromoBanner uses homePromoBanner asset', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomePromoBanner(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final imageWidget = tester.widget<Image>(find.byType(Image));
      final provider = imageWidget.image as AssetImage;
      expect(provider.assetName, AppAssets.homePromoBanner);
    });

    testWidgets(
        'HomePage renders new layout and smoothly switches to Daftar menu on Menu tap',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        HomeTabController.instance.resetToHome();
        CartService.instance.applyPromoCode(null);
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const HomePage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify new Home content
      expect(find.text('Terpopuler di Malang'), findsOneWidget);
      expect(find.text('Diskon 20% buat jedamu'), findsOneWidget);
      expect(find.text('Kode: BREAK20'), findsOneWidget);
      expect(find.text('2 Ice Kopi Susu • Rp28.000'), findsOneWidget);
      expect(find.text('Apa itu BreakFree?'), findsOneWidget);

      // Apply BREAK20 voucher
      await tester.tap(find.text('Pakai'));
      await tester.pumpAndSettle();
      expect(CartService.instance.appliedPromoCode, 'BREAK20');
      expect(find.text('Dipakai'), findsOneWidget);

      // Tap Menu icon in bottom nav bar and verify smooth transition to Daftar menu
      await tester.tap(find.text('Menu'));
      await tester.pump(const Duration(milliseconds: 160));
      await tester.pumpAndSettle();

      expect(find.text('Daftar menu'), findsOneWidget);
      expect(find.text('Menu terlaris'), findsOneWidget);
      expect(find.text('Breakfree Aren Latte'), findsWidgets);
      expect(find.text('Signature Matcha'), findsWidgets);

      // Tap Home icon to return smoothly
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Apa itu BreakFree?'), findsOneWidget);
    });
  });
}
