import 'package:injectable/injectable.dart';
import 'package:settings_domain/settings_domain.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [LoadTheme, SaveTheme],
  throwOnMissingDependencies: true,
)
void configureSettingsPresentationPackage() {}
