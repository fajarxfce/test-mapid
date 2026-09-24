import 'package:core_common/core_common.dart';
import 'package:core_testing/core_testing.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart' show GetItHelper;
import 'package:settings_data/settings_data.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:test/test.dart';

void main() {
  test(
    'settings module supplies working use cases without app registration',
    () async {
      final container = GetIt.asNewInstance();
      addTearDown(container.reset);
      final preferences = FakePreferenceStore();
      container.registerSingleton<PreferenceStore>(preferences);
      await SettingsDataPackageModule().init(GetItHelper(container));

      final loadTheme = container<LoadTheme>();
      final saveTheme = container<SaveTheme>();
      expect(container<LoadTheme>(), isNot(same(loadTheme)));
      expect(container<SaveTheme>(), isNot(same(saveTheme)));

      expect(
        ((await loadTheme()) as Success<AppThemeMode>).value,
        AppThemeMode.system,
      );
      expect(await saveTheme(AppThemeMode.dark), isA<Success<void>>());
      expect(preferences.values['theme'], 'dark');
      expect(
        ((await container<LoadTheme>()()) as Success<AppThemeMode>).value,
        AppThemeMode.dark,
      );
    },
  );
}
