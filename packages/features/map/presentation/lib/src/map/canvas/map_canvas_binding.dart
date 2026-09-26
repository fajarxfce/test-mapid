import 'dart:async';

import 'package:core_location_domain/core_location_domain.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/bloc/map_effect.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/canvas/map_canvas_port.dart';
import 'package:rxdart/rxdart.dart';

/// Route-owned wiring. Receives inputs and callbacks, never a Bloc instance.
final class MapCanvasBinding {
  MapCanvasBinding({
    required MapCanvasPort canvas,
    required MapLayer? initialLayer,
    required LocationFix? initialLocation,
    required Stream<MapLayer?> layers,
    required Stream<LocationFix?> locations,
    required Stream<MapEffect> effects,
    required void Function(MapEvent) onEvent,
  }) {
    _subscriptions.addAll([
      layers.startWith(initialLayer).distinct().listen(canvas.showPlaces),
      locations
          .startWith(initialLocation)
          .distinct()
          .listen(canvas.updateLocation),
      canvas.statuses.listen(
        (status) => onEvent(MapCanvasStatusChanged(status)),
      ),
      canvas.selections.listen((id) => onEvent(MapPlaceSelected(id))),
      effects.listen((effect) {
        switch (effect) {
          case FocusMapCamera(:final focus):
            canvas.focus(focus);
          case ZoomMapCamera(:final amount):
            canvas.zoomBy(amount);
          case ReloadMapCanvas():
            canvas.retry();
        }
      }),
    ]);
  }

  final _subscriptions = <StreamSubscription<Object?>>[];

  Future<void> close() =>
      Future.wait(_subscriptions.map((subscription) => subscription.cancel()));
}
