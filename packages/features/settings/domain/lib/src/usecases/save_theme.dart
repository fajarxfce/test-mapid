import 'package:core_common/core_common.dart';
import 'package:settings_domain/src/entities/app_theme_mode.dart';
import 'package:settings_domain/src/repositories/settings_repository.dart';

final class SaveTheme {
  const SaveTheme(this._repository);
  final SettingsRepository _repository;
  Future<Result<void>> call(AppThemeMode mode) => _repository.saveTheme(mode);
}
