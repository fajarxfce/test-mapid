import 'package:core_common/core_common.dart';
import 'package:injectable/injectable.dart';
import 'package:settings_domain/settings_domain.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [PreferenceStore],
  throwOnMissingDependencies: true,
)
void configureSettingsDataPackage() {}

/// Settings owns its use-case bindings alongside its repository registration.
@module
abstract class SettingsModule {
  @injectable
  LoadTheme loadTheme(SettingsRepository repository) => LoadTheme(repository);

  @injectable
  SaveTheme saveTheme(SettingsRepository repository) => SaveTheme(repository);
}
