import 'dart:convert';
import 'dart:math';

import 'package:core_common/core_common.dart';
import 'package:crypto/crypto.dart';
import 'package:identity_data/src/requests/oauth_exchange_request.dart';
import 'package:identity_domain/identity_domain.dart';

/// One authorization-code transaction, bound to its callback, state and PKCE verifier.
final class OAuthAttempt {
  OAuthAttempt({required this.redirectUri}) {
    final random = Random.secure();
    state = _randomValue(random);
    verifier = _randomValue(random);
  }

  final Uri redirectUri;
  late final String state;
  late final String verifier;
  String get challenge => base64Url
      .encode(sha256.convert(utf8.encode(verifier)).bytes)
      .replaceAll('=', '');

  Uri authorizationUri(Uri apiOrigin, IdentityProvider provider) =>
      apiOrigin.replace(
        path: '/auth/oauth/${provider.name}/authorize',
        queryParameters: {
          'redirect_uri': redirectUri.toString(),
          'state': state,
          'code_challenge': challenge,
          'code_challenge_method': 'S256',
        },
      );

  OAuthExchangeRequest exchangeRequest(Uri callback) {
    if (callback.replace(query: '').toString() !=
            redirectUri.replace(query: '').toString() ||
        callback.hasFragment) {
      throw const Failure(
        FailureKind.security,
        'The sign-in callback was rejected.',
      );
    }
    final params = callback.queryParametersAll;
    if (params.values.any((values) => values.length != 1) ||
        params['state']?.single != state) {
      throw const Failure(
        FailureKind.security,
        'The sign-in state was rejected.',
      );
    }
    final code = params['code']?.single;
    final error = params['error']?.single;
    if (error != null) {
      if (code != null) {
        throw const Failure(
          FailureKind.security,
          'The sign-in callback was rejected.',
        );
      }
      if (error == 'access_denied') {
        throw const Failure(FailureKind.cancelled, 'Sign-in was cancelled.');
      }
      throw const Failure(
        FailureKind.unauthorized,
        'The provider could not sign you in.',
      );
    }
    if (code == null || code.trim().isEmpty || code.length > 2048) {
      throw const Failure(
        FailureKind.invalidResponse,
        'Sign-in did not return an authorization code.',
      );
    }
    return OAuthExchangeRequest(
      code: code,
      codeVerifier: verifier,
      redirectUri: redirectUri.toString(),
    );
  }

  static String _randomValue(Random random) => base64Url
      .encode(List<int>.generate(32, (_) => random.nextInt(256)))
      .replaceAll('=', '');
}
