import 'package:core_common/core_common.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class SecureCredentialStore implements CredentialStore {
  SecureCredentialStore(this._storage, String namespace)
    : _key = '$namespace.access_token';
  final FlutterSecureStorage _storage;
  final String _key;
  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);
  @override
  Future<void> clear() => _storage.delete(key: _key);
}
