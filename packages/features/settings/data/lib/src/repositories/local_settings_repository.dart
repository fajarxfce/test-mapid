import 'package:core_common/core_common.dart';
import 'package:injectable/injectable.dart';
import 'package:settings_domain/settings_domain.dart';

@LazySingleton(as: SettingsRepository)
final class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._preferences);
  final PreferenceStore _preferences;

  @override
  Future<Result<AppThemeMode>> loadTheme() => safeStorageCall(() async {
    final saved = await _preferences.read('theme');
    return AppThemeMode.values
            .where((mode) => mode.name == saved)
            .firstOrNull ??
        AppThemeMode.system;
  }, message: 'Unable to load appearance preferences.');

  @override
  Future<Result<void>> saveTheme(AppThemeMode mode) => safeStorageCall(
    () => _preferences.write('theme', mode.name),
    message: 'Appearance changed for this session, but could not be saved.',
  );
}
