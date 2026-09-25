import 'dart:async';
import 'dart:math';

import 'package:core_common/core_common.dart';
import 'package:injectable/injectable.dart';
import 'package:map_presentation/src/map/models/map_scene.dart';
import 'package:map_presentation/src/map/rendering/map_renderer.dart';
import 'package:map_presentation/src/map/rendering/maplibre_session.dart';
import 'package:maplibre_gl/maplibre_gl.dart' show MapLibreMapController;
import 'package:rxdart/rxdart.dart';

/// Retains the desired scene across native creation and style replacement.
@injectable
final class MapLibreRenderer implements MapRenderer {
  static const styleUrl = 'https://tiles.openfreemap.org/styles/liberty';
  MapScene _scene = const MapScene();
  MapLibreSession? _session;
  StreamSubscription<MapRenderStatus>? _statusSubscription;
  final _statuses = BehaviorSubject<MapRenderStatus>.seeded(
    MapRenderStatus.waitingForMap,
  );

  @override
  Stream<MapRenderStatus> get statuses => _statuses.stream.distinct();

  /// Native widget binding; never part of the Bloc-facing contract.
  void attach(MapLibreMapController controller) {
    if (_statuses.isClosed || controller.isDisposed) return;
    unawaited(_statusSubscription?.cancel());
    unawaited(_session?.close());
    final session = MapLibreSession(controller, styleUrl: styleUrl);
    _session = session;
    _statusSubscription = session.statuses.listen((status) {
      if (!_statuses.isClosed && identical(session, _session)) {
        _statuses.add(status);
      }
    });
  }

  void styleLoaded() => _session?.styleLoaded(_scene);

  @override
  void render(MapScene scene) {
    _scene = scene;
    _session?.render(scene);
  }

  @override
  void focus(MapScene scene) {
    _scene = scene;
    _session?.render(scene, refocus: true);
  }

  @override
  void zoomBy(double amount) => _session?.zoomBy(amount);

  @override
  void reloadStyle() => _session?.reloadStyle();

  @override
  Future<Result<String?>> placeAt(Point<double> point) =>
      _session?.placeAt(point) ?? Future.value(const Success(null));

  /// The route owns this adapter; the SDK widget owns its native controller.
  Future<void> close() async {
    if (_statuses.isClosed) return;
    await Future.wait<void>([
      _statuses.close(),
      if (_statusSubscription != null) _statusSubscription!.cancel(),
      if (_session != null) _session!.close(),
    ]);
    _session = null;
  }
}
