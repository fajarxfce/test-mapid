import 'package:core_lifecycle_data/src/datasources/app_lifecycle_data_source.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AppLifecycleDataSource)
final class FlutterAppLifecycleDataSource implements AppLifecycleDataSource {
  const FlutterAppLifecycleDataSource();

  @override
  Stream<bool> watchForeground() => Stream<bool>.multi((controller) {
    final listener = AppLifecycleListener(
      onStateChange: (state) {
        switch (state) {
          case AppLifecycleState.resumed:
            controller.add(true);
          case AppLifecycleState.hidden:
          case AppLifecycleState.paused:
          case AppLifecycleState.detached:
            controller.add(false);
          // An inactive application can still be visible, e.g. behind a dialog.
          case AppLifecycleState.inactive:
            break;
        }
      },
    );
    controller.add(switch (WidgetsBinding.instance.lifecycleState) {
      AppLifecycleState.hidden ||
      AppLifecycleState.paused ||
      AppLifecycleState.detached => false,
      _ => true,
    });
    controller.onCancel = listener.dispose;
  }).distinct();
}
