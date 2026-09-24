import 'package:core_common/core_common.dart';

final class FakeCredentialStore implements CredentialStore {
  String? token;
  bool failWrites = false;
  @override
  Future<String?> read() async => token;
  @override
  Future<void> write(String value) async {
    if (failWrites) throw StateError('Storage unavailable');
    token = value;
  }

  @override
  Future<void> clear() async => token = null;
}
