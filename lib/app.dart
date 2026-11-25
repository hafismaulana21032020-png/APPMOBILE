import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

class BreakFreeApp extends StatelessWidget {
  const BreakFreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BreakFree',
      theme: AppTheme.lightTheme,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return LayoutBuilder(
          builder: (context, constraints) {
            // Jika dijalankan di Chrome / layar lebar (> 500px), tampilkan otomatis
            // dalam bingkai viewport HP agar tidak perlu membuka DevTools Inspect manual.
            if (constraints.maxWidth <= 500) {
              return child;
            }

            final frameWidth = math.min(412.0, constraints.maxWidth - 24);
            final frameHeight = math.min(844.0, constraints.maxHeight - 24);
            final mediaQuery = MediaQuery.of(context);

            return Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1F1916),
                    Color(0xFF2D241F),
                    Color(0xFF1A1512),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: frameWidth + 16,
                  height: frameHeight + 16,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF120F0D),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: const Color(0xFF473A32),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 36,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: MediaQuery(
                      data: mediaQuery.copyWith(
                        size: Size(frameWidth, frameHeight),
                        padding: EdgeInsets.zero,
                        viewPadding: EdgeInsets.zero,
                      ),
                      child: SizedBox(
                        width: frameWidth,
                        height: frameHeight,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Alias for backward compatibility
typedef MyApp = BreakFreeApp;

