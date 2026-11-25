import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/google_auth_service.dart';
import '../../../../core/services/web_google_sign_in/web_google_helper.dart';
import '../../../../core/theme/app_colors.dart';

class GoogleSignInButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSignUp;

  const GoogleSignInButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSignUp = false,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  Future<bool>? _webInitFuture;

  @override
  void initState() {
    super.initState();
    if (kIsWeb && GoogleAuthService.instance.isWebClientConfigured) {
      _webInitFuture = GoogleAuthService.instance.ensureInitialized();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb &&
        GoogleAuthService.instance.isWebClientConfigured &&
        _webInitFuture != null) {
      return FutureBuilder<bool>(
        future: _webInitFuture,
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return SizedBox(
              width: double.infinity,
              height: 50,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final rendered = buildWebGoogleSignInButton(
                    minimumWidth: constraints.maxWidth,
                    isSignUp: widget.isSignUp,
                  );
                  if (rendered != null) {
                    return Center(child: rendered);
                  }
                  return _buildFallbackButton();
                },
              ),
            );
          }
          return _buildFallbackButton();
        },
      );
    }

    return _buildFallbackButton();
  }

  Widget _buildFallbackButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.inputBorderColor, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.primaryBrown,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CustomPaint(painter: _GoogleLogoPainter()),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      widget.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;
    final strokeWidth = w * 0.21;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Merah (atas kiri-kanan)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.55, 1.85, false, paint);

    // Kuning (kiri)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.45, 1.35, false, paint);

    // Hijau (bawah)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.80, 1.70, false, paint);

    // Biru (kanan bawah + palang G)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.08, 0.95, false, paint);

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(w - strokeWidth * 0.15, center.dy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
