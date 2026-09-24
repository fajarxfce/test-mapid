abstract interface class PreferenceStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}
