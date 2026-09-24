import 'package:core_common/core_common.dart';
import 'package:settings_domain/src/entities/app_theme_mode.dart';

abstract interface class SettingsRepository {
  Future<Result<AppThemeMode>> loadTheme();
  Future<Result<void>> saveTheme(AppThemeMode mode);
}
