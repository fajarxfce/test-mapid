import 'dart:convert';

import 'package:core_common/core_common.dart';
import 'package:crypto/crypto.dart';
import 'package:identity_data/identity_data.dart';
import 'package:identity_data/src/oauth/oauth_attempt.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:test/test.dart';

void main() {
  final redirect = Uri.parse('dev.example.app.oauth://oauth/callback');
  late OAuthAttempt attempt;
  setUp(() => attempt = OAuthAttempt(redirectUri: redirect));
  Uri callback(Map<String, String> params) =>
      redirect.replace(queryParameters: {'state': attempt.state, ...params});
  Matcher failure(FailureKind kind) =>
      throwsA(isA<Failure>().having((failure) => failure.kind, 'kind', kind));

  test('each transaction has fresh state and RFC 7636 S256 challenge', () {
    final next = OAuthAttempt(redirectUri: redirect);
    expect(next.state, isNot(attempt.state));
    expect(next.verifier, isNot(attempt.verifier));
    expect(attempt.verifier, matches(RegExp(r'^[A-Za-z0-9_-]{43}$')));
    final uri = attempt.authorizationUri(
      Uri.parse('https://api.example.com'),
      IdentityProvider.google,
    );
    expect(uri.path, '/auth/oauth/google/authorize');
    expect(uri.queryParameters['code_challenge_method'], 'S256');
    expect(
      uri.queryParameters['code_challenge'],
      base64Url
          .encode(sha256.convert(utf8.encode(attempt.verifier)).bytes)
          .replaceAll('=', ''),
    );
    expect(uri.toString(), isNot(contains(attempt.verifier)));
    final request = attempt.exchangeRequest(callback({'code': 'one-use-code'}));
    expect(request.toJson(), {
      'code': 'one-use-code',
      'code_verifier': attempt.verifier,
      'redirect_uri': redirect.toString(),
    });
  });

  test('rejects a different scheme, host, path, port, fragment or state', () {
    final valid = callback({'code': 'code'});
    for (final invalid in [
      valid.replace(scheme: 'attacker.oauth'),
      valid.replace(host: 'attacker'),
      valid.replace(path: '/other'),
      valid.replace(port: 8080),
      valid.replace(fragment: 'code=stolen'),
      callback({'code': 'code', 'state': 'wrong'}),
      redirect.replace(queryParameters: {'code': 'code'}),
    ]) {
      expect(
        () => attempt.exchangeRequest(invalid),
        failure(FailureKind.security),
      );
    }
  });

  test(
    'rejects duplicate parameters and ambiguous success/error responses',
    () {
      final valid = callback({'code': 'code'});
      for (final uri in [
        Uri.parse('$valid&code=other'),
        Uri.parse('$valid&state=${attempt.state}'),
        callback({'code': 'code', 'error': 'access_denied'}),
      ]) {
        expect(
          () => attempt.exchangeRequest(uri),
          failure(FailureKind.security),
        );
      }
    },
  );

  test('maps cancellation without trusting provider descriptions', () {
    expect(
      () => attempt.exchangeRequest(callback({'error': 'access_denied'})),
      failure(FailureKind.cancelled),
    );
    expect(
      () => attempt.exchangeRequest(
        callback({'error': 'server_error', 'error_description': 'secret'}),
      ),
      throwsA(
        isA<Failure>().having(
          (value) => value.message,
          'message',
          isNot(contains('secret')),
        ),
      ),
    );
    expect(
      () => attempt.exchangeRequest(callback({})),
      failure(FailureKind.invalidResponse),
    );
  });

  test('configuration only accepts supported callback transports', () {
    for (final uri in [
      null,
      'http://example.com/auth',
      'https://example.com/auth?code=x',
      'javascript:alert(1)',
      'file:///auth',
      'http://localhost/auth',
      'dev.app.oauth://oauth/callback#x',
    ]) {
      expect(
        () => OAuthConfiguration(
          apiOrigin: Uri.parse('https://api.example.com'),
          providers: {IdentityProvider.google},
          redirectUri: uri == null ? null : Uri.parse(uri),
        ),
        throwsArgumentError,
      );
    }
    for (final uri in [
      'https://app.example.com/auth.html',
      'http://localhost:43821/auth.html',
      redirect.toString(),
    ]) {
      expect(
        OAuthConfiguration(
          apiOrigin: Uri.parse('https://api.example.com'),
          providers: {IdentityProvider.google},
          redirectUri: Uri.parse(uri),
        ).providers,
        {IdentityProvider.google},
      );
    }
  });
}
