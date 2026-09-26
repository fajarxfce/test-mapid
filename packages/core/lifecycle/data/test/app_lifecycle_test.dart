import 'package:core_lifecycle_data/src/datasources/flutter_app_lifecycle_data_source.dart';
import 'package:core_lifecycle_data/src/repositories/flutter_app_lifecycle_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repository = FlutterAppLifecycleRepository(
    const FlutterAppLifecycleDataSource(),
  );

  for (final entry in {
    AppLifecycleState.resumed: true,
    AppLifecycleState.inactive: true,
    AppLifecycleState.hidden: false,
    AppLifecycleState.paused: false,
    AppLifecycleState.detached: false,
  }.entries) {
    test('reports initial visibility for ${entry.key}', () async {
      WidgetsBinding.instance.handleAppLifecycleStateChanged(entry.key);
      expect(await repository.watchForeground().first, entry.value);
    });
  }

  test(
    'focus loss preserves visibility and disposal stops observation',
    () async {
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      final values = <bool>[];
      final subscription = repository.watchForeground().listen(values.add);
      addTearDown(subscription.cancel);
      await Future<void>.delayed(Duration.zero);
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.inactive,
      );
      await Future<void>.delayed(Duration.zero);
      expect(values, [true]);
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.hidden,
      );
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.paused,
      );
      await Future<void>.delayed(Duration.zero);
      expect(values, [true, false]);
      for (final state in [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        WidgetsBinding.instance.handleAppLifecycleStateChanged(state);
      }
      await Future<void>.delayed(Duration.zero);
      expect(values, [true, false, true]);
      await subscription.cancel();
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.paused,
      );
      await Future<void>.delayed(Duration.zero);
      expect(values, [true, false, true]);
    },
  );
}
