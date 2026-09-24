import 'package:core_common/core_common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:identity_data/src/oauth/oauth_browser.dart';

/// System browser authentication. No provider credentials or embedded login WebView.
final class SystemOAuthBrowser implements OAuthBrowser {
  @override
  Future<String> authenticate(Uri authorizationUri, Uri redirectUri) async {
    final desktop =
        !kIsWeb &&
        {
          TargetPlatform.linux,
          TargetPlatform.windows,
        }.contains(defaultTargetPlatform);
    if (desktop &&
        (redirectUri.scheme != 'http' || redirectUri.host != 'localhost')) {
      throw const Failure(
        FailureKind.validation,
        'Desktop sign-in needs a localhost callback.',
      );
    }
    if (kIsWeb &&
        (!{'http', 'https'}.contains(redirectUri.scheme) ||
            redirectUri.origin != Uri.base.origin)) {
      throw const Failure(
        FailureKind.security,
        'Web sign-in needs a callback on this site.',
      );
    }
    try {
      return await FlutterWebAuth2.authenticate(
        url: authorizationUri.toString(),
        callbackUrlScheme: desktop
            ? redirectUri.toString()
            : redirectUri.scheme,
        options: FlutterWebAuth2Options(
          useWebview: false,
          httpsHost: redirectUri.host,
          httpsPath: redirectUri.path,
        ),
      );
    } on PlatformException catch (error) {
      if ({'CANCELED', 'CANCELLED'}.contains(error.code.toUpperCase())) {
        throw const Failure(FailureKind.cancelled, 'Sign-in was cancelled.');
      }
      if (error.code.toUpperCase() == 'TIMEOUT') {
        throw const Failure(
          FailureKind.timeout,
          'Sign-in timed out. Please try again.',
        );
      }
      throw const Failure(
        FailureKind.unexpected,
        'Unable to open the sign-in browser.',
      );
    }
  }
}
