import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:identity_data/src/config/oauth_configuration.dart';
import 'package:identity_data/src/datasources/demo/demo_oauth_browser.dart';
import 'package:identity_data/src/oauth/oauth_browser.dart';
import 'package:identity_data/src/oauth/system_oauth_browser.dart';
import 'package:identity_data/src/session/identity_session.dart';
import 'package:identity_data/src/session/persistent_identity_session.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [
    Dio,
    CredentialStore,
    AppEnvironment,
    OAuthConfiguration,
  ],
  throwOnMissingDependencies: true,
)
void configureIdentityDataPackage() {}

/// Identity owns its use-case bindings while domain stays free of DI annotations.
@module
abstract class IdentityModule {
  @lazySingleton
  IdentitySession identitySession(PersistentIdentitySession session) => session;

  @Named(mainApi)
  @lazySingleton
  HttpAuthentication httpAuthentication(PersistentIdentitySession session) =>
      session;

  @lazySingleton
  OAuthBrowser oauthBrowser(
    AppEnvironment environment,
    @Named(mainApi) Dio dio,
  ) => environment.isDemo ? DemoOAuthBrowser(dio) : SystemOAuthBrowser();

  @lazySingleton
  LoginWithProvider loginWithProvider(IdentityRepository repository) =>
      LoginWithProvider(repository);

  @injectable
  GetIdentityProviders getIdentityProviders(IdentityRepository repository) =>
      GetIdentityProviders(repository);

  @injectable
  Login login(IdentityRepository repository) => Login(repository);

  @injectable
  RestoreSession restoreSession(IdentityRepository repository) =>
      RestoreSession(repository);

  @injectable
  Logout logout(IdentityRepository repository) => Logout(repository);

  @injectable
  WatchSession watchSession(IdentityRepository repository) =>
      WatchSession(repository);

  @injectable
  GetCurrentSession getCurrentSession(IdentityRepository repository) =>
      GetCurrentSession(repository);

  @injectable
  ExpireDemoSession expireDemoSession(DemoSessionRepository repository) =>
      ExpireDemoSession(repository);
}
