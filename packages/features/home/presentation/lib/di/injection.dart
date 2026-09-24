import 'package:core_common/core_common.dart';
import 'package:get_it/get_it.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [
    GetIt,
    WatchSession,
    GetCurrentSession,
    RestoreSession,
    Logout,
    ExpireDemoSession,
    AppEnvironment,
  ],
  throwOnMissingDependencies: true,
)
void configureHomePresentationPackage() {}
