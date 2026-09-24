import 'package:flutter/widgets.dart';
import 'package:map_presentation/src/map/canvas/gestures/map_pan_gesture_observer.dart';

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
