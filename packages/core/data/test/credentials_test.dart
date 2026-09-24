import 'package:core_data/core_data.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'native credentials are isolated per flavor and can be cleared',
    () async {
      final values = <String, String>{};
      const channel = MethodChannel(
        'plugins.it_nomads.com/flutter_secure_storage',
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            final args = Map<String, Object?>.from(call.arguments as Map);
            final key = args['key'] as String;
            switch (call.method) {
              case 'write':
                values[key] = args['value'] as String;
              case 'read':
                return values[key];
              case 'delete':
                values.remove(key);
            }
            return null;
          });
      final dev = SecureCredentialStore(
        const FlutterSecureStorage(),
        'dev.demo',
      );
      final prod = SecureCredentialStore(
        const FlutterSecureStorage(),
        'prod.demo',
      );
      await dev.write('dev-token');
      expect(await prod.read(), isNull);
      expect(await dev.read(), 'dev-token');
      await dev.clear();
      expect(await dev.read(), isNull);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    },
  );
  test('new web memory store does not restore previous credentials', () async {
    final store = MemoryCredentialStore();
    await store.write('token');
    expect(await store.read(), 'token');
    expect(await MemoryCredentialStore().read(), isNull);
  });
}
