import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart' as web_only;
import 'package:web/web.dart' as web;

String? getWebMetaGoogleClientId() {
  final content = web.document
      .querySelector('meta[name=google-signin-client_id]')
      ?.getAttribute('content')
      ?.trim();
  if (content == null ||
      content.isEmpty ||
      content.toUpperCase().contains('YOUR_GOOGLE')) {
    return null;
  }
  return content;
}

Widget? buildWebGoogleSignInButton({
  double? minimumWidth,
  bool isSignUp = false,
}) {
  final safeWidth = minimumWidth?.clamp(180.0, 400.0).toDouble();
  return web_only.renderButton(
    configuration: web_only.GSIButtonConfiguration(
      type: web_only.GSIButtonType.standard,
      shape: web_only.GSIButtonShape.rectangular,
      size: web_only.GSIButtonSize.large,
      text: isSignUp
          ? web_only.GSIButtonText.signupWith
          : web_only.GSIButtonText.signinWith,
      theme: web_only.GSIButtonTheme.outline,
      minimumWidth: safeWidth,
    ),
  );
}
