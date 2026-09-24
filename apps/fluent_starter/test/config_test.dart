import 'package:fluent_starter/config/app_config.dart';
import 'package:fluent_starter/config/app_flavor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity_domain/identity_domain.dart';

void main() {
  for (final flavor in AppFlavor.values) {
    test('${flavor.name} explicitly supports demo and API', () {
      expect(
        AppConfig.parse(flavor: flavor.name, backend: 'demo').isDemo,
        isTrue,
      );
      expect(
        AppConfig.parse(
          flavor: flavor.name,
          backend: 'api',
          baseUrl: 'https://api.example.com',
        ).isDemo,
        isFalse,
      );
    });
  }
  test('native and Dart flavor must agree', () {
    expect(
      () =>
          AppConfig.parse(flavor: 'dev', backend: 'demo', nativeFlavor: 'prod'),
      throwsArgumentError,
    );
  });
  test('API mode rejects absent, insecure or ambiguous origins', () {
    for (final url in [
      '',
      'http://api.example.com',
      'https://a:b@example.com',
      'https://api.example.com/v1',
    ]) {
      expect(
        () => AppConfig.parse(flavor: 'prod', backend: 'api', baseUrl: url),
        throwsArgumentError,
      );
    }
    expect(
      () => AppConfig.parse(flavor: 'unknown', backend: 'demo'),
      throwsArgumentError,
    );
    expect(
      () => AppConfig.parse(flavor: 'dev', backend: 'unknown'),
      throwsArgumentError,
    );
  });
  test('API providers are opt-in and require an explicit callback', () {
    final disabled = AppConfig.parse(
      flavor: 'dev',
      backend: 'api',
      baseUrl: 'https://api.example.com',
    );
    expect(disabled.oauthProviders, isEmpty);
    final configured = AppConfig.parse(
      flavor: 'dev',
      backend: 'api',
      baseUrl: 'https://api.example.com',
      oauthProviders: 'google, github',
      oauthRedirectUri: 'dev.example.fluentstarter.dev.oauth://oauth/callback',
    );
    expect(configured.oauthProviders, IdentityProvider.values.toSet());
    expect(
      () => AppConfig.parse(
        flavor: 'dev',
        backend: 'api',
        baseUrl: 'https://api.example.com',
        oauthProviders: 'google',
      ),
      throwsArgumentError,
    );
    expect(
      () => AppConfig.parse(
        flavor: 'dev',
        backend: 'api',
        baseUrl: 'https://api.example.com',
        oauthProviders: 'unknown',
        oauthRedirectUri: 'https://example.com/auth.html',
      ),
      throwsArgumentError,
    );
  });
}
