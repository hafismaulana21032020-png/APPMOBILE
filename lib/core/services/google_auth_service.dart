import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';
import 'web_google_sign_in/web_google_helper.dart';

/// Helper service untuk autentikasi Google Sign-In menggunakan google_sign_in v7+
/// yang aman dari pemanggilan init()/initialize() berulang di Android maupun Flutter Web,
/// lalu memverifikasi ID Token ke backend Express (/api/v1/mobile/auth/google).
class GoogleAuthService {
  GoogleAuthService._();
  static final GoogleAuthService instance = GoogleAuthService._();

  // Diset via: flutter run --dart-define=GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com
  static const String _dartDefineClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue:
        '937310521024-gialhub9d9nin1nit8md9ei0thsd99qt.apps.googleusercontent.com',
  );

  bool _isInitialized = false;
  Future<bool>? _initFuture;
  bool _listenerAttached = false;
  bool _isMobileAuthenticateActive = false;
  bool _isProcessingWebEvent = false;
  String? _lastInitError;

  final StreamController<Map<String, dynamic>> _webSignInResultController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream hasil autentikasi Google khusus Web (dari renderButton / One Tap).
  Stream<Map<String, dynamic>> get webSignInResults =>
      _webSignInResultController.stream;

  String? get _effectiveClientId {
    final defineId = _dartDefineClientId.trim();
    if (defineId.isNotEmpty) return defineId;
    if (kIsWeb) {
      return getWebMetaGoogleClientId();
    }
    return null;
  }

  /// Mengetahui apakah Google Client ID sudah terpasang untuk platform Web.
  bool get isWebClientConfigured => kIsWeb && _effectiveClientId != null;

  bool get isInitialized => _isInitialized;

  String? get lastInitError => _lastInitError;

  /// Menjamin GoogleSignIn.instance.initialize() hanya dipanggil SEKALI per sesi.
  Future<bool> ensureInitialized() {
    if (_isInitialized) return Future<bool>.value(true);
    _initFuture ??= _doInitialize();
    return _initFuture!;
  }

  Future<bool> _doInitialize() async {
    _lastInitError = null;
    final configuredClientId = _effectiveClientId;

    // Di Flutter Web, google_sign_in_web akan melempar AssertionError lalu menandai
    // _isInitCalled = true permanen jika clientId tidak tersedia. Cegah sebelum memanggil initialize().
    if (kIsWeb && configuredClientId == null) {
      _lastInitError =
          'Login Google di Web belum aktif karena Google Client ID belum diisi. '
          'Tambahkan <meta name="google-signin-client_id" content="..."/> di web/index.html '
          'atau jalankan dengan --dart-define=GOOGLE_CLIENT_ID=..., atau gunakan login Email.';
      _initFuture = null;
      return false;
    }

    try {
      await GoogleSignIn.instance.initialize(
        // google_sign_in_web melarang serverClientId (!= null) karena melempar AssertionError
        clientId: kIsWeb ? configuredClientId : null,
        serverClientId: kIsWeb ? null : configuredClientId,
      );
      _isInitialized = true;
      _attachAuthEventListener();
      return true;
    } catch (e) {
      final msg = e.toString();
      // Jika instance JS/platform sebelumnya sudah terinisialisasi (mis. hot restart / race),
      // jangan gagalkan alur sign-in dan jangan panggil initialize() lagi.
      if (msg.contains('already been called')) {
        _isInitialized = true;
        _attachAuthEventListener();
        return true;
      }

      debugPrint('GoogleAuthService initialize error: $e');
      _lastInitError = kIsWeb
          ? 'Konfigurasi Google Sign-In Web belum lengkap. Periksa Google Client ID Anda.'
          : 'Gagal menginisialisasi layanan Google Sign-In: $e';
      _initFuture = null;
      return false;
    }
  }

  void _attachAuthEventListener() {
    if (_listenerAttached) return;
    _listenerAttached = true;

    GoogleSignIn.instance.authenticationEvents.listen(
      (event) async {
        if (_isMobileAuthenticateActive) return;
        if (event is GoogleSignInAuthenticationEventSignIn) {
          if (_isProcessingWebEvent) return;
          _isProcessingWebEvent = true;
          try {
            final idToken = event.user.authentication.idToken;
            if (idToken == null || idToken.isEmpty) {
              _webSignInResultController.add({
                'success': false,
                'message':
                    'Google tidak mengembalikan ID Token yang valid. Periksa Client ID Anda.',
              });
              return;
            }
            final res = await ApiService.instance.googleLogin(idToken);
            _webSignInResultController.add(res);
          } catch (e) {
            _webSignInResultController.add({
              'success': false,
              'message': 'Gagal memverifikasi akun Google ke server: $e',
            });
          } finally {
            _isProcessingWebEvent = false;
          }
        }
      },
      onError: (Object error) {
        if (_isMobileAuthenticateActive) return;
        if (error is GoogleSignInException &&
            error.code == GoogleSignInExceptionCode.canceled) {
          _webSignInResultController.add({
            'success': false,
            'cancelled': true,
            'message': 'Masuk dengan Google dibatalkan.',
          });
          return;
        }
        _webSignInResultController.add({
          'success': false,
          'message': 'Autentikasi Google gagal: $error',
        });
      },
    );
  }

  /// Memulai alur login/daftar Google dan mengirim ID Token ke Backend Express.
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final ready = await ensureInitialized();
      if (!ready) {
        return {
          'success': false,
          'message': _lastInitError ??
              'Layanan Google Sign-In belum dikonfigurasi pada perangkat ini.',
        };
      }

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        if (kIsWeb) {
          // Di Flutter Web, autentikasi ditangani oleh widget renderButton() / One Tap
          await GoogleSignIn.instance.attemptLightweightAuthentication();
          return {
            'success': false,
            'cancelled': true,
            'message': 'Silakan pilih akun melalui tombol Google Sign-In Web.',
          };
        }
        return {
          'success': false,
          'message':
              'Platform ini belum mendukung tombol masuk Google secara langsung. Silakan gunakan Android/Web.',
        };
      }

      _isMobileAuthenticateActive = true;
      try {
        final account = await GoogleSignIn.instance.authenticate(
          scopeHint: const ['email', 'profile'],
        );

        final idToken = account.authentication.idToken;
        if (idToken == null || idToken.isEmpty) {
          return {
            'success': false,
            'message':
                'Google tidak mengembalikan ID Token. Pastikan GOOGLE_CLIENT_ID (Web Client ID) sudah diset via --dart-define.',
          };
        }

        return await ApiService.instance.googleLogin(idToken);
      } finally {
        _isMobileAuthenticateActive = false;
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return {
          'success': false,
          'cancelled': true,
          'message': 'Masuk dengan Google dibatalkan.',
        };
      }
      return {
        'success': false,
        'message': e.description ?? 'Autentikasi Google gagal (${e.code.name}).',
      };
    } catch (e) {
      debugPrint('GoogleAuthService error: $e');
      return {
        'success': false,
        'message': 'Gagal terhubung ke layanan Google Sign-In: $e',
      };
    }
  }

  Future<void> signOut() async {
    try {
      if (_isInitialized) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (e) {
      debugPrint('GoogleAuthService signOut warning: $e');
    }
  }
}
