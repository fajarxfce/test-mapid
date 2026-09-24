import 'package:core_common/core_common.dart';
import 'package:core_testing/core_testing.dart';
import 'package:settings_data/settings_data.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:test/test.dart';

class MockPreferenceStore extends Mock implements PreferenceStore {}

void main() {
  test('saved theme survives a new repository instance', () async {
    final store = FakePreferenceStore();
    await LocalSettingsRepository(store).saveTheme(AppThemeMode.dark);
    final result = await LocalSettingsRepository(store).loadTheme();
    expect((result as Success<AppThemeMode>).value, AppThemeMode.dark);
  });

  test('unknown preference falls back to the system theme', () async {
    final store = FakePreferenceStore()..values['theme'] = 'obsolete-value';
    final result = await LocalSettingsRepository(store).loadTheme();
    expect((result as Success<AppThemeMode>).value, AppThemeMode.system);
  });

  test(
    'storage failures stay typed and do not escape the data layer',
    () async {
      final store = MockPreferenceStore();
      when(() => store.read('theme')).thenThrow(StateError('unavailable'));
      when(() => store.write('theme', 'light'))
          .thenThrow(StateError('unavailable'));
      final repository = LocalSettingsRepository(store);
      final loaded = await repository.loadTheme();
      final saved = await repository.saveTheme(AppThemeMode.light);
      expect(
        (loaded as FailureResult<AppThemeMode>).failure.kind,
        FailureKind.storage,
      );
      expect((saved as FailureResult<void>).failure.kind, FailureKind.storage);
    },
  );
}
