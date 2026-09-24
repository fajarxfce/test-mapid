import 'package:fluent_starter/config/app_flavor.dart';
import 'package:fluent_starter/config/backend_mode.dart';
import 'package:flutter/services.dart';
import 'package:identity_domain/identity_domain.dart';

final class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.backend,
    required this.baseUrl,
    this.oauthProviders = const {},
    this.oauthRedirectUri = '',
  });
  final AppFlavor flavor;
  final BackendMode backend;
  final String baseUrl;
  final Set<IdentityProvider> oauthProviders;
  final String oauthRedirectUri;
  String get label => '${flavor.name} · ${backend.name}';
  String get storageNamespace =>
      'fluent_starter.${flavor.name}.${backend.name}';
  bool get isDemo => backend == BackendMode.demo;
  factory AppConfig.fromEnvironment() => AppConfig.parse(
    flavor: const String.fromEnvironment('FLAVOR', defaultValue: 'dev'),
    backend: const String.fromEnvironment('BACKEND', defaultValue: 'demo'),
    baseUrl: const String.fromEnvironment('API_BASE_URL'),
    nativeFlavor: appFlavor,
    oauthProviders: const String.fromEnvironment('OAUTH_PROVIDERS'),
    oauthRedirectUri: const String.fromEnvironment('OAUTH_REDIRECT_URI'),
  );
  factory AppConfig.parse({
    required String flavor,
    required String backend,
    String baseUrl = '',
    String? nativeFlavor,
    String oauthProviders = '',
    String oauthRedirectUri = '',
  }) {
    if (nativeFlavor != null && nativeFlavor != flavor) {
      throw ArgumentError(
        'Native flavor and FLAVOR must match. Use tool/app.dart.',
      );
    }
    final selectedFlavor = AppFlavor.values.byName(flavor);
    final selectedBackend = BackendMode.values.byName(backend);
    final providers = selectedBackend == BackendMode.demo
        ? IdentityProvider.values.toSet()
        : oauthProviders
              .split(',')
              .map((name) => name.trim())
              .where((name) => name.isNotEmpty)
              .map(IdentityProvider.values.byName)
              .toSet();
    if (selectedBackend == BackendMode.api &&
        providers.isNotEmpty &&
        oauthRedirectUri.isEmpty) {
      throw ArgumentError(
        'OAUTH_REDIRECT_URI is required when OAUTH_PROVIDERS is enabled.',
      );
    }
    if (selectedBackend == BackendMode.api) {
      final uri = Uri.tryParse(baseUrl);
      if (uri == null ||
          uri.scheme != 'https' ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty ||
          uri.hasQuery ||
          uri.hasFragment ||
          (uri.path != '' && uri.path != '/')) {
        throw ArgumentError(
          'API_BASE_URL must be an HTTPS origin without credentials, path, query or fragment.',
        );
      }
    }
    return AppConfig(
      flavor: selectedFlavor,
      backend: selectedBackend,
      baseUrl: selectedBackend == BackendMode.demo
          ? 'https://demo.invalid'
          : baseUrl,
      oauthProviders: Set.unmodifiable(providers),
      oauthRedirectUri: selectedBackend == BackendMode.demo
          ? 'dev.example.fluentstarter${selectedFlavor == AppFlavor.prod ? '' : '.$flavor'}.oauth://oauth/callback'
          : oauthRedirectUri,
    );
  }
}
