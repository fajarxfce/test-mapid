import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart' show GestureRecognizerFactory;

/// Observes intentional drags without claiming MapLibre's native gestures.
class MapPanGestureObserver extends OneSequenceGestureRecognizer {
  VoidCallback? onPan;
  final _origins = <int, Offset>{};
  bool _reported = false;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _origins[event.pointer] = event.position;
    super.addAllowedPointer(event);
    // Keep receiving pointer events, but leave the arena to the native view.
    resolvePointer(event.pointer, GestureDisposition.rejected);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent && !_reported) {
      final origin = _origins[event.pointer];
      if (origin != null &&
          (event.position - origin).distance >
              computePanSlop(event.kind, gestureSettings)) {
        _reported = true;
        onPan?.call();
      }
    }
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _origins.remove(event.pointer);
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) => _reported = false;

  @override
  String get debugDescription => 'map pan observer';

  @override
  void dispose() {
    _origins.clear();
    super.dispose();
  }
}

/// RawGestureDetector owns the observer and refreshes its callback on rebuild.
class MapPanGestureFactory
    extends GestureRecognizerFactory<MapPanGestureObserver> {
  const MapPanGestureFactory({required this.onPan});
  final VoidCallback onPan;

  @override
  MapPanGestureObserver constructor() => MapPanGestureObserver();

  @override
  void initializer(MapPanGestureObserver instance) => instance.onPan = onPan;
}
