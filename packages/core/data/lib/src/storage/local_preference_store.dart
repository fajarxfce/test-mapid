import 'package:core_common/core_common.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class LocalPreferenceStore implements PreferenceStore {
  LocalPreferenceStore(this._preferences, this.namespace);
  final SharedPreferencesAsync _preferences;
  final String namespace;
  factory LocalPreferenceStore.create(String namespace) =>
      LocalPreferenceStore(SharedPreferencesAsync(), namespace);
  @override
  Future<String?> read(String key) => _preferences.getString('$namespace.$key');
  @override
  Future<void> write(String key, String value) =>
      _preferences.setString('$namespace.$key', value);
}
