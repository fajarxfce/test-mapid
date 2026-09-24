import 'package:fluent_starter/config/app_config.dart';
import 'package:fluent_starter/config/app_flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads the requested flavor and explicit layer configuration', () {
    final config = AppConfig.parse(
      flavor: 'staging',
      nativeFlavor: 'staging',
      apiKey: ' test-key ',
      layerId: 'layer',
      projectId: 'project',
    );
    expect(config.flavor, AppFlavor.staging);
    expect(config.apiKey, 'test-key');
  });
  test('rejects missing credentials without including their values', () {
    expect(
      () => AppConfig.parse(
        flavor: 'dev',
        apiKey: '',
        layerId: 'layer',
        projectId: 'project',
      ),
      throwsFormatException,
    );
    expect(
      () => AppConfig.parse(
        flavor: 'dev',
        apiKey: 'test-private-key',
        layerId: '',
        projectId: 'project',
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'safe message',
          isNot(contains('test-private-key')),
        ),
      ),
    );
  });
  test('native and Dart flavors must match', () {
    expect(
      () => AppConfig.parse(
        flavor: 'dev',
        nativeFlavor: 'prod',
        apiKey: 'test-key',
        layerId: 'layer',
        projectId: 'project',
      ),
      throwsFormatException,
    );
  });
}
