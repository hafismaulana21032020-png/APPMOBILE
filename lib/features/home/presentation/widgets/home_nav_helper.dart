import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../controllers/home_tab_controller.dart';
import 'ai_assistant_sheet.dart';

/// Shared bottom-nav tap handler for secondary pages outside [HomePage].
void handleSecondaryBottomNavTap(
  BuildContext context,
  int index, {
  required int currentIndex,
  bool popOnCurrent = false,
}) {
  if (index == currentIndex) {
    if (popOnCurrent) {
      Navigator.maybePop(context);
    }
    return;
  }

  switch (index) {
    case 0:
      HomeTabController.instance.resetToHome();
      Navigator.popUntil(context, (route) => route.isFirst);
      break;
    case 1:
      Navigator.pushNamed(context, AppRoutes.menu);
      break;
    case 2:
      showAiAssistantSheet(context);
      break;
    case 3:
      Navigator.pushNamed(context, AppRoutes.account);
      break;
  }
}

