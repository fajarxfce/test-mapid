import 'package:core_common/core_common.dart';
import 'package:get_it/get_it.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [
    GetIt,
    Login,
    LoginWithProvider,
    GetIdentityProviders,
    AppEnvironment,
  ],
  throwOnMissingDependencies: true,
)
void configureAuthPresentationPackage() {}
