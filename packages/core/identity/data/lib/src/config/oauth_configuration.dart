import 'package:identity_domain/identity_domain.dart';

/// Public client settings. Provider client secrets belong exclusively to the backend.
final class OAuthConfiguration {
  OAuthConfiguration({
    required this.apiOrigin,
    this.redirectUri,
    Set<IdentityProvider> providers = const {},
  }) : providers = Set.unmodifiable(providers) {
    if (apiOrigin.scheme != 'https' ||
        apiOrigin.host.isEmpty ||
        apiOrigin.userInfo.isNotEmpty ||
        apiOrigin.hasQuery ||
        apiOrigin.hasFragment ||
        (apiOrigin.path.isNotEmpty && apiOrigin.path != '/')) {
      throw ArgumentError('OAuth API must use an HTTPS origin.');
    }
    if (providers.isEmpty) return;
    final uri = redirectUri;
    if (uri == null ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        uri.path.isEmpty) {
      throw ArgumentError(
        'OAuth requires a callback URI without query or fragment.',
      );
    }
    final loopback =
        uri.scheme == 'http' &&
        uri.host == 'localhost' &&
        uri.hasPort &&
        uri.port > 0;
    final native =
        uri.scheme.endsWith('.oauth') &&
        RegExp(r'^[a-z][a-z0-9+.-]*$').hasMatch(uri.scheme);
    if (uri.scheme != 'https' && !loopback && !native) {
      throw ArgumentError(
        'Use HTTPS, a localhost port, or a native .oauth scheme.',
      );
    }
  }

  final Uri apiOrigin;
  final Uri? redirectUri;
  final Set<IdentityProvider> providers;
}
