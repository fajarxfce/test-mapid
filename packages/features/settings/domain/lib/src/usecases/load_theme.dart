import 'package:core_common/core_common.dart';
import 'package:settings_domain/src/entities/app_theme_mode.dart';
import 'package:settings_domain/src/repositories/settings_repository.dart';

final class LoadTheme {
  const LoadTheme(this._repository);
  final SettingsRepository _repository;
  Future<Result<AppThemeMode>> call() => _repository.loadTheme();
}
