import 'dart:async';
import 'dart:math';

import 'package:core_common/core_common.dart';
import 'package:map_presentation/src/map/canvas/models/map_scene.dart';
import 'package:map_presentation/src/map/canvas/rendering/diff_map_scene.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_libre_camera.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_libre_layers.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_render_status.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_scene_change.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_style.dart';
import 'package:maplibre_gl/maplibre_gl.dart' show MapLibreMapController;
import 'package:synchronized/synchronized.dart';

/// Owns operations for exactly one native controller. The widget disposes it.
final class MapLibreRenderSession {
  MapLibreRenderSession(this._controller)
    : _layers = MapLibreLayers(_controller),
      _camera = MapLibreCamera(_controller) {
    _waitForStyle();
  }

  final MapLibreMapController _controller;
  final MapLibreLayers _layers;
  final MapLibreCamera _camera;
  final _operations = Lock();
  final _statuses = StreamController<MapRenderStatus>();
  MapScene? _applied;
  Timer? _styleTimeout;
  bool _styleReady = false;

  Stream<MapRenderStatus> get statuses => _statuses.stream.distinct();
  bool get _closed => _statuses.isClosed || _controller.isDisposed;

  void styleLoaded(MapScene scene) {
    _styleTimeout?.cancel();
    unawaited(
      _execute(() async {
        _styleReady = true;
        _applied = null;
        await _draw(scene);
      }),
    );
  }

  void render(MapScene scene, {bool refocus = false}) {
    unawaited(
      _execute(() async {
        if (_styleReady) await _draw(scene, refocus: refocus);
      }),
    );
  }

  void zoomBy(double amount) {
    unawaited(
      _execute(() async {
        if (_styleReady) await _camera.zoomBy(amount);
      }),
    );
  }

  void reloadStyle() {
    unawaited(
      _execute(() async {
        _waitForStyle();
        await _controller.setStyle(MapStyle.liberty);
      }),
    );
  }

  Future<Result<String?>> placeAt(Point<double> point) =>
      _execute(() async => _styleReady ? await _layers.placeAt(point) : null);

  void _waitForStyle() {
    _styleReady = false;
    _applied = null;
    _styleTimeout?.cancel();
    _statuses.add(MapRenderStatus.loadingStyle);
    _styleTimeout = Timer(const Duration(seconds: 25), () {
      if (!_closed) _statuses.add(MapRenderStatus.styleTimeout);
    });
  }

  Future<void> _draw(MapScene scene, {bool refocus = false}) async {
    for (final change in diffMapScene(_applied, scene, refocus: refocus)) {
      if (_closed) return;
      await switch (change) {
        MapPlacesChanged(:final layer) => _layers.showPlaces(layer),
        MapLocationChanged(:final location) => _layers.showLocation(location),
        MapCameraChanged(:final scene) => _camera.focus(scene),
      };
    }
    if (_closed) return;
    // Only a complete render advances the diff baseline. Partial failures retry.
    _applied = scene;
    _statuses.add(MapRenderStatus.ready);
  }

  Future<Result<T>> _execute<T>(Future<T> Function() operation) =>
      _operations.synchronized<Result<T>>(() async {
        if (_closed) {
          return const FailureResult(
            Failure(FailureKind.cancelled, 'The native map has been released.'),
          );
        }
        try {
          final value = await operation();
          if (_closed) {
            return const FailureResult(
              Failure(
                FailureKind.cancelled,
                'The native map has been released.',
              ),
            );
          }
          return Success(value);
        } on Exception {
          _applied = null;
          if (!_closed) _statuses.add(MapRenderStatus.renderingFailure);
          return const FailureResult(
            Failure(FailureKind.unexpected, 'The native map operation failed.'),
          );
        }
      });

  Future<void> close() {
    _styleTimeout?.cancel();
    return _statuses.close();
  }
}
