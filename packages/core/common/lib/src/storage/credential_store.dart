abstract interface class CredentialStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}
