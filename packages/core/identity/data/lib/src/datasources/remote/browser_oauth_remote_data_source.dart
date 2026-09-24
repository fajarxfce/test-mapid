import 'package:identity_data/src/config/oauth_configuration.dart';
import 'package:identity_data/src/datasources/remote/oauth_remote_data_source.dart';
import 'package:identity_data/src/oauth/oauth_attempt.dart';
import 'package:identity_data/src/oauth/oauth_browser.dart';
import 'package:identity_data/src/responses/login_response.dart';
import 'package:identity_data/src/services/auth_api.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: OAuthRemoteDataSource)
final class BrowserOAuthRemoteDataSource implements OAuthRemoteDataSource {
  BrowserOAuthRemoteDataSource(this._api, this._browser, this._configuration);

  final AuthApi _api;
  final OAuthBrowser _browser;
  final OAuthConfiguration _configuration;

  @override
  Set<IdentityProvider> get providers => _configuration.providers;

  @override
  Future<LoginResponse> login(IdentityProvider provider) async {
    final attempt = OAuthAttempt(redirectUri: _configuration.redirectUri!);
    final callback = await _browser.authenticate(
      attempt.authorizationUri(_configuration.apiOrigin, provider),
      attempt.redirectUri,
    );
    final request = attempt.exchangeRequest(Uri.parse(callback));
    return await _api.exchangeOAuth(provider.name, request);
  }
}
