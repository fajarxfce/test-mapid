import 'package:flutter/widgets.dart';

/// Observes application visibility at the platform boundary, not in a widget.
/// Inactive is ignored: a permission dialog must not restart its own request.
Stream<bool> watchAppForeground() => Stream<bool>.multi((controller) {
  final listener = AppLifecycleListener(
    onStateChange: (state) {
      switch (state) {
        case AppLifecycleState.resumed:
          controller.add(true);
        case AppLifecycleState.hidden:
        case AppLifecycleState.paused:
        case AppLifecycleState.detached:
          controller.add(false);
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
