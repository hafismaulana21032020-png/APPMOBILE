import 'package:breakfree_app/app.dart';
import 'package:breakfree_app/core/constants/app_assets.dart';
import 'package:breakfree_app/core/routes/app_router.dart';
import 'package:breakfree_app/core/theme/app_theme.dart';
import 'package:breakfree_app/core/utils/app_formatters.dart';
import 'package:breakfree_app/core/utils/app_validators.dart';
import 'package:breakfree_app/features/account/domain/services/user_service.dart';
import 'package:breakfree_app/features/account/presentation/pages/account_page.dart';
import 'package:breakfree_app/features/account/presentation/pages/notifications_page.dart';
import 'package:breakfree_app/features/account/presentation/pages/profile_page.dart';
import 'package:breakfree_app/features/account/presentation/pages/settings_page.dart';
import 'package:breakfree_app/features/account/presentation/widgets/account_stats_row.dart';
import 'package:breakfree_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:breakfree_app/features/auth/presentation/pages/login_page.dart';
import 'package:breakfree_app/features/auth/presentation/pages/register_page.dart';
import 'package:breakfree_app/features/cart/domain/services/cart_service.dart';
import 'package:breakfree_app/features/cart/presentation/pages/cart_page.dart';
import 'package:breakfree_app/features/home/data/menu_data.dart';
import 'package:breakfree_app/features/home/domain/services/ai_chat_service.dart';
import 'package:breakfree_app/features/home/domain/services/menu_service.dart';
import 'package:breakfree_app/features/home/presentation/controllers/home_tab_controller.dart';
import 'package:breakfree_app/features/home/presentation/pages/ai_chat_page.dart';
import 'package:breakfree_app/features/home/presentation/pages/coffee_menu_page.dart';
import 'package:breakfree_app/features/home/presentation/pages/food_menu_page.dart';
import 'package:breakfree_app/features/home/presentation/pages/home_page.dart';
import 'package:breakfree_app/features/home/presentation/pages/menu_page.dart';
import 'package:breakfree_app/features/home/presentation/pages/non_coffee_menu_page.dart';
import 'package:breakfree_app/features/home/presentation/pages/snack_menu_page.dart';
import 'package:breakfree_app/features/home/presentation/widgets/ai_assistant_sheet.dart';
import 'package:breakfree_app/features/home/presentation/widgets/home_promo_banner.dart';
import 'package:breakfree_app/features/order/domain/services/order_service.dart';
import 'package:breakfree_app/features/order/presentation/pages/order_tracking_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

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

      expect(
        AppValidators.evaluatePasswordSimilarity('kopi1234', 'kopi1234'),
        PasswordSimilarity.identical,
      );
      expect(
        AppValidators.evaluatePasswordSimilarity('kopi1234', 'kopi1235'),
        PasswordSimilarity.similar,
      );
      expect(
        AppValidators.evaluatePasswordSimilarity('kopi1234', 'Kopi1234'),
        PasswordSimilarity.similar,
      );
      expect(
        AppValidators.evaluatePasswordSimilarity('kopi1234', 'kopi1234!'),
        PasswordSimilarity.similar,
      );
      expect(
        AppValidators.evaluatePasswordSimilarity('kopi1234', 'MatchaSegar99'),
        PasswordSimilarity.distinct,
      );
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
      'AiChatPage': const AiChatPage(),
      'OrderTrackingPage': const OrderTrackingPage(),
      'SettingsPage': const SettingsPage(),
      'NotificationsPage': const NotificationsPage(),
    };

    for (final size in [const Size(360, 780), const Size(320, 568)]) {
      for (final entry in pages.entries) {
        testWidgets(
            '${entry.key} renders without overflow at ${size.width}x${size.height}',
            (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            MenuService.instance.stopAutoSync();
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
          MenuService.instance.stopAutoSync();
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

    testWidgets('RegisterPage validates inputs and terms checkbox before submit',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        UserService.instance.clear();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const RegisterPage(),
        ),
      );

      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(5));

      await tester.enterText(fields.at(0), 'Budi Santoso');
      await tester.enterText(fields.at(1), 'budi@breakfree.id');
      await tester.enterText(fields.at(2), '081234567890');
      await tester.enterText(fields.at(3), 'lemah');
      await tester.enterText(fields.at(4), 'lemah');

      await tester.ensureVisible(find.text('Daftar'));
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Kata sandi minimal 8 karakter dan mengandung huruf serta angka'),
        findsOneWidget,
      );

      await tester.enterText(fields.at(3), 'kopi1234');
      await tester.enterText(fields.at(4), 'kopi9999');
      await tester.ensureVisible(find.text('Daftar'));
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi kata sandi tidak cocok'), findsOneWidget);

      await tester.enterText(fields.at(4), 'kopi1234');
      await tester.ensureVisible(find.text('Daftar'));
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Silakan setujui Syarat dan Ketentuan terlebih dahulu'),
        findsOneWidget,
      );

      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('HomePage search finds products across categories',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        MenuService.instance.stopAutoSync();
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
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Indomie Goreng');
      await tester.pumpAndSettle();

      expect(find.text('Indomie Goreng'), findsWidgets);
      MenuService.instance.stopAutoSync();
    });

    testWidgets('CartPage rejects invalid promo code and supports BREAK20 offline fallback',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      CartService.instance.clear();
      // Tambah item agar subtotal >= Rp 30.000 (syarat minimum BREAK20)
      for (var i = 0; i < 6; i++) {
        CartService.instance.addProduct(breakfreeMenuItems.first);
      }
      addTearDown(() {
        CartService.instance.clear();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const CartPage(),
        ),
      );
      await tester.pumpAndSettle();

      final promoField = find.byType(TextField).first;
      await tester.ensureVisible(promoField);
      await tester.enterText(promoField, 'FAKEKOPIKAMPUS');
      await tester.ensureVisible(find.text('Terapkan'));
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      expect(CartService.instance.appliedPromoCode, isNull);
      expect(find.byType(SnackBar), findsOneWidget);

      await tester.ensureVisible(promoField);
      await tester.enterText(promoField, 'BREAK20');
      await tester.ensureVisible(find.text('Terapkan'));
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      expect(CartService.instance.appliedPromoCode, 'BREAK20');
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
        'HomePage renders layout, handles voucher tap, and switches to Daftar menu on Menu tap',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        MenuService.instance.stopAutoSync();
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

      // Verify Home content
      expect(find.text('Terpopuler di BreakFree'), findsOneWidget);
      expect(find.text('Diskon 20% buat jedamu'), findsOneWidget);
      expect(find.text('Kode: BREAK20'), findsOneWidget);
      expect(find.text('2 Ice Kopi Susu • Rp28.000'), findsOneWidget);
      expect(find.text('Apa itu BreakFree?'), findsOneWidget);

      // Tap Pakai when backend promos aren't fetched
      await tester.ensureVisible(find.text('Pakai'));
      await tester.tap(find.text('Pakai'));
      await tester.pumpAndSettle();
      expect(
        find.text('Saat ini belum ada promo voucher yang aktif.'),
        findsOneWidget,
      );

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
      MenuService.instance.stopAutoSync();
    });

    testWidgets('AI Chat Service and AiChatPage respond intelligently to queries',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        AiChatService.instance.resetChat();
      });

      // Verify initial state
      AiChatService.instance.resetChat();
      expect(AiChatService.instance.messages.isNotEmpty, isTrue);
      expect(
        AiChatService.instance.messages.first.text.contains('Barista AI'),
        isTrue,
      );

      // Pump AiChatPage
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const AiChatPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and greeting
      expect(find.text('Barista AI BreakFree'), findsWidgets);
      expect(find.text('Online'), findsWidgets);
      expect(find.text('Kopi Manis & Creamy'), findsOneWidget);

      // Tap suggestion chip for sweet coffee
      await tester.tap(find.text('Kopi Manis & Creamy'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Barista responds with sweet coffee suggestions
      expect(find.textContaining('Breakfree Aren Latte'), findsWidgets);
      expect(find.text('+ Tambah'), findsWidgets);

      // Send promo question
      final inputField = find.byType(TextField);
      await tester.enterText(inputField, 'ada promo apa aja?');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.textContaining('BREAK20'), findsWidgets);
    });

    testWidgets('AiAssistantSheet opens and switches between Chatbot and Recommendations',
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
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => showAiAssistantSheet(ctx),
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Chat Barista tab is active by default
      expect(find.text('Chat Barista AI'), findsOneWidget);
      expect(find.text('Rekomendasi'), findsOneWidget);

      // Switch to Rekomendasi tab
      await tester.tap(find.text('Rekomendasi'));
      await tester.pumpAndSettle();

      expect(find.text('Menu Pilihan Barista Hari Ini'), findsOneWidget);
      expect(find.text('Punya Pertanyaan Selera Khusus?'), findsOneWidget);

      // Tap back to Chat Barista
      await tester.tap(find.text('Chat Barista AI'));
      await tester.pumpAndSettle();
      expect(find.text('Barista AI BreakFree'), findsWidgets);
    });

    testWidgets('OrderTrackingPage renders empty state and switches between Aktif and Riwayat tabs',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      OrderService.instance.clearAll();
      addTearDown(() {
        OrderService.instance.clearAll();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const OrderTrackingPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lacak Pesanan'), findsOneWidget);
      expect(find.text('Belum Ada Pesanan Aktif'), findsOneWidget);
      expect(find.text('Lihat Menu Kopi & Makanan'), findsOneWidget);

      // Switch to Riwayat tab
      await tester.tap(find.textContaining('Riwayat'));
      await tester.pumpAndSettle();
      expect(find.text('Belum ada riwayat transaksi.'), findsOneWidget);

      // Switch back to Pesanan Aktif
      await tester.tap(find.text('Pesanan Aktif'));
      await tester.pumpAndSettle();
      expect(find.text('Belum Ada Pesanan Aktif'), findsOneWidget);
    });

    testWidgets('AccountPage Lacak Pesanan navigates to OrderTrackingPage',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      OrderService.instance.clearAll();
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const AccountPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Lacak Pesanan button in AccountPage
      await tester.tap(find.text('Lacak Pesanan'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(OrderTrackingPage), findsOneWidget);
      expect(find.text('Belum Ada Pesanan Aktif'), findsOneWidget);
    });

    testWidgets('SettingsPage menus are functional on tap', (tester) async {
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
          home: const SettingsPage(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Test Bahasa picker
      await tester.tap(find.text('Bahasa'));
      await tester.pumpAndSettle();
      expect(find.text('Pilih Bahasa / Language'), findsOneWidget);
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(find.text('English'), findsOneWidget);

      // 2. Test Tampilan / Theme picker
      await tester.tap(find.text('Tampilan'));
      await tester.pumpAndSettle();
      expect(find.text('Pilih Tema Tampilan'), findsOneWidget);
      await tester.tap(find.text('Gelap (Dark)'));
      await tester.pumpAndSettle();
      expect(find.text('Gelap'), findsOneWidget);

      // 3. Test Ubah kata sandi sheet Step 1 verification
      await tester.tap(find.text('Ubah kata sandi'));
      await tester.pumpAndSettle();
      expect(find.text('Verifikasi Kata Sandi Lama'), findsNWidgets(2));
      expect(find.text('Kata Sandi Lama'), findsOneWidget);
      expect(
        find.text('Lupa kata sandi? Reset dengan Gmail (OTP)'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Verifikasi Kata Sandi Lama'));
      await tester.pumpAndSettle();
      expect(find.text('Kata sandi lama harus diisi.'), findsOneWidget);

      // Dismiss bottom sheet before continuing
      Navigator.of(tester.element(find.text('Kata Sandi Lama'))).pop();
      await tester.pumpAndSettle();

      // 4. Test Kebijakan privasi sheet
      await tester.ensureVisible(find.text('Kebijakan privasi'));
      await tester.tap(find.text('Kebijakan privasi'));
      await tester.pumpAndSettle();
      expect(find.text('Kebijakan Privasi'), findsOneWidget);
      expect(find.text('Saya Mengerti'), findsOneWidget);
      await tester.tap(find.text('Saya Mengerti'));
      await tester.pumpAndSettle();

      // 5. Test Hapus akun dialog
      await tester.ensureVisible(find.text('Hapus akun'));
      await tester.tap(find.text('Hapus akun'));
      await tester.pumpAndSettle();
      expect(find.text('Hapus Akun Permanen?'), findsOneWidget);
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.text('Hapus Akun Permanen?'), findsNothing);
    });

    testWidgets('AccountPage Keluar akun shows validation dialog before logout',
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
          home: const AccountPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Keluar akun
      await tester.ensureVisible(find.text('Keluar akun'));
      await tester.tap(find.text('Keluar akun'));
      await tester.pumpAndSettle();

      // Verify validation dialog appears instead of immediately logging out
      expect(find.text('Keluar dari Akun?'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);

      // Tap Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Dialog is dismissed and user remains on AccountPage
      expect(find.text('Keluar dari Akun?'), findsNothing);
      expect(find.byType(AccountPage), findsOneWidget);

      // Tap Keluar akun again and confirm
      await tester.ensureVisible(find.text('Keluar akun'));
      await tester.tap(find.text('Keluar akun'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();

      // Successfully redirected to LoginPage
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('HomePage notification button opens NotificationsPage and can navigate back',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        MenuService.instance.stopAutoSync();
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
      await tester.pumpAndSettle();

      // Verify notification button exists on HomePage
      final notifBtn = find.byTooltip('Notifikasi');
      expect(notifBtn, findsOneWidget);

      // Tap notification button
      await tester.tap(notifBtn);
      await tester.pumpAndSettle();

      // Verifies it opened NotificationsPage
      expect(find.byType(NotificationsPage), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verifies it returned to HomePage
      expect(find.byType(HomePage), findsOneWidget);
      MenuService.instance.stopAutoSync();
    });

    testWidgets('AccountPage header has no top notification button',
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
          home: const AccountPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header has BreakFree and Akun Saya
      expect(find.text('Akun Saya'), findsOneWidget);
      // Verify no notification tooltip button in header
      expect(find.byTooltip('Notifikasi'), findsNothing);
    });

    testWidgets(
        'SettingsPage Ubah kata sandi validates Step 2 and links ForgotPassword via Gmail',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      UserService.instance.setFromJson({
        'name': 'BUDI SANTOSO',
        'email': 'budi@gmail.com',
        'hasPassword': false,
      });
      addTearDown(() {
        UserService.instance.clear();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const SettingsPage(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ubah kata sandi'));
      await tester.pumpAndSettle();
      // Akun Google tanpa password lama tetap wajib verifikasi OTP Gmail dulu (tidak langsung lompat ke sandi baru)
      expect(find.text('Verifikasi via OTP Gmail'), findsOneWidget);
      expect(find.text('Kirim & Verifikasi OTP via Gmail'), findsOneWidget);
      expect(find.text('Kata Sandi Baru (min. 6 karakter)'), findsNothing);

      // Verifikasi langsung Step 2 validasi kata sandi baru + similarity
      Navigator.of(tester.element(find.text('Verifikasi via OTP Gmail'))).pop();
      await tester.pumpAndSettle();
      final settingsCtx = tester.element(find.byType(SettingsPage));
      showVerifiedChangePasswordSheet(settingsCtx, skipVerificationForTest: true);
      await tester.pumpAndSettle();
      expect(find.text('Ubah Kata Sandi'), findsOneWidget);

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '123');
      await tester.enterText(textFields.at(1), '123');
      await tester.tap(find.text('Simpan Kata Sandi Baru'));
      await tester.pumpAndSettle();
      expect(find.text('Kata sandi baru minimal 6 karakter.'), findsOneWidget);

      await tester.enterText(textFields.at(0), 'baru1234');
      await tester.enterText(textFields.at(1), 'beda1234');
      await tester.tap(find.text('Simpan Kata Sandi Baru'));
      await tester.pumpAndSettle();
      expect(find.text('Konfirmasi kata sandi tidak cocok.'), findsOneWidget);

      Navigator.of(tester.element(find.text('Ubah Kata Sandi'))).pop();
      await tester.pumpAndSettle();

      // Tap Ubah kata sandi untuk akun Google lagi & lanjut ke OTP Gmail
      await tester.tap(find.text('Ubah kata sandi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kirim & Verifikasi OTP via Gmail'));
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordPage), findsOneWidget);
      expect(find.text('budi@gmail.com'), findsOneWidget);
    });

    testWidgets(
        'ProfilePage requires current password verification or Gmail reset before saving',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      UserService.instance.setFromJson({
        'name': 'BUDI SANTOSO',
        'email': 'budi@gmail.com',
        'hasPassword': true,
      });
      addTearDown(() {
        UserService.instance.clear();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const ProfilePage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verifikasi Sekarang'), findsOneWidget);
      expect(find.text('Ubah kata sandi akun'), findsOneWidget);

      await tester.ensureVisible(find.text('Simpan perubahan'));
      await tester.tap(find.text('Simpan perubahan'));
      await tester.pumpAndSettle();

      expect(find.text('Verifikasi Akun Dulu'), findsOneWidget);
      expect(find.text('Kata Sandi Saat Ini'), findsOneWidget);
      final dialogForgotLink = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Lupa kata sandi? Reset dengan Gmail'),
      );
      expect(dialogForgotLink, findsOneWidget);

      await tester.tap(dialogForgotLink);
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordPage), findsOneWidget);
      expect(find.text('budi@gmail.com'), findsOneWidget);
    });
  });
}
