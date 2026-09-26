import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/models/map_effect.dart';
import 'package:map_presentation/src/map/models/map_scene.dart';
import 'package:map_presentation/src/map/rendering/map_renderer.dart';
import 'package:rxdart/rxdart.dart';

/// Route-owned connection between page outputs and the native rendering port.
/// Receives streams/callbacks, never resolves or owns the page Bloc.
final class MapCanvasBinding {
  MapCanvasBinding({
    required MapRenderer renderer,
    required MapScene initialScene,
    required Stream<MapScene> scenes,
    required Stream<MapEffect> effects,
    required void Function(MapEvent) onEvent,
  }) : _renderer = renderer,
       _scene = initialScene {
    _subscriptions.addAll([
      scenes.listen((scene) {
        if (scene == _scene) return;
        _scene = scene;
        renderer.render(scene);
      }),
      renderer.statuses.listen(
        (status) => onEvent(MapRenderStatusChanged(status)),
      ),
      effects.whereType<MapCanvasCommand>().listen(_runCommand),
      effects
          .whereType<PickMapPlace>()
          .switchMap(
            (request) => renderer
                .placeAt(request.point)
                .asStream()
                .map((result) => (request: request, result: result)),
          )
          .listen((pick) {
            if (pick.result case Success(:final value)) {
              onEvent(
                MapPlacePicked(
                  value,
                  layer: pick.request.layer,
                  selection: pick.request.selection,
                ),
              );
            }
          }),
    ]);
    renderer.render(initialScene);
  }

  final MapRenderer _renderer;
  final _subscriptions = <StreamSubscription<Object?>>[];
  MapScene _scene;

  void _runCommand(MapCanvasCommand command) {
    switch (command) {
      case FocusMapCamera(:final focus):
        // An intervening pan supersedes a queued focus command.
        if (focus == _scene.focus) _renderer.focus(_scene);
      case ZoomMapCamera(:final amount):
        _renderer.zoomBy(amount);
      case ReloadMapCanvas():
        _renderer.reloadStyle();
    }
  }

  Future<void> close() =>
      Future.wait(_subscriptions.map((subscription) => subscription.cancel()));
}
