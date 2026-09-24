import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:core_common/core_common.dart';
import 'package:map_presentation/src/map/canvas/models/map_scene.dart';
import 'package:map_presentation/src/map/canvas/rendering/diff_map_scene.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_libre_camera.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_libre_layers.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_native_operation.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_render_baseline.dart';
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
  MapRenderBaseline _applied = const MapRenderBaseline();
  ({MapScene scene, bool refocus})? _pending;
  Timer? _styleTimeout;
  bool _styleReady = false;
  bool _renderScheduled = false;

  Stream<MapRenderStatus> get statuses => _statuses.stream.distinct();
  bool get _closed => _statuses.isClosed || _controller.isDisposed;

  void styleLoaded(MapScene scene) {
    if (_closed) return;
    _styleTimeout?.cancel();
    _styleReady = false;
    render(scene);
    unawaited(
      _operations.synchronized(() {
        if (_closed) return;
        _styleReady = true;
        _applied = const MapRenderBaseline();
        _scheduleRender();
      }),
    );
  }

  void render(MapScene scene, {bool refocus = false}) {
    if (_closed) return;
    _pending = (
      scene: scene,
      refocus:
          refocus ||
          (_pending?.refocus == true && _pending?.scene.focus == scene.focus),
    );
    _scheduleRender();
  }

  void _scheduleRender() {
    if (_closed || !_styleReady || _pending == null || _renderScheduled) return;
    _renderScheduled = true;
    unawaited(
      _operations.synchronized(() async {
        final request = _pending;
        _pending = null;
        try {
          if (!_closed && _styleReady && request != null) {
            await _draw(request.scene, refocus: request.refocus);
          }
        } finally {
          _renderScheduled = false;
          // Enqueue one more draw behind explicit commands, using the newest scene.
          _scheduleRender();
        }
      }),
    );
  }

  void zoomBy(double amount) {
    unawaited(
      _operations.synchronized(() async {
        if (_styleReady) {
          await _execute(
            MapNativeOperation.camera,
            () => _camera.zoomBy(amount),
          );
        }
      }),
    );
  }

  void reloadStyle() {
    if (_closed) return;
    // Stop an in-flight draw before its next native write or camera command.
    _waitForStyle();
    unawaited(
      _operations.synchronized(
        () => _execute(
          MapNativeOperation.style,
          () => _controller.setStyle(MapStyle.liberty),
        ),
      ),
    );
  }

  Future<Result<String?>> placeAt(Point<double> point) =>
      _operations.synchronized(
        () => _execute(
          MapNativeOperation.query,
          () async => _styleReady ? await _layers.placeAt(point) : null,
        ),
      );

  void _waitForStyle() {
    _styleReady = false;
    _applied = const MapRenderBaseline();
    _styleTimeout?.cancel();
    _statuses.add(MapRenderStatus.loadingStyle);
    _styleTimeout = Timer(const Duration(seconds: 25), () {
      if (!_closed) _statuses.add(MapRenderStatus.styleTimeout);
    });
  }

  Future<void> _draw(MapScene scene, {required bool refocus}) async {
    for (final change in diffMapScene(_applied, scene, refocus: refocus)) {
      if (_closed || !_styleReady) return;
      if (change is MapCameraChanged && _pending != null) {
        // A pan or newer position supersedes the camera intent captured above.
        final next = _pending!;
        _pending = (
          scene: next.scene,
          refocus: next.refocus || (refocus && next.scene.focus == scene.focus),
        );
        return;
      }
      final result = await switch (change) {
        MapPlacesChanged(:final layer) => _execute(
          MapNativeOperation.sources,
          () => _layers.showPlaces(layer),
        ),
        MapLocationChanged(:final location) => _execute(
          MapNativeOperation.sources,
          () => _layers.showLocation(location),
        ),
        MapCameraChanged(:final reframe) => _execute(
          MapNativeOperation.camera,
          () => _camera.focus(scene, reframe: reframe),
        ),
      };
      if (_closed || !_styleReady || result is FailureResult<void>) return;
      _applied = _applied.afterSuccess(change);
    }
    if (!_closed && _styleReady) _statuses.add(MapRenderStatus.ready);
  }

  Future<Result<T>> _execute<T>(
    MapNativeOperation operation,
    Future<T> Function() run,
  ) async {
    if (_closed) {
      return const FailureResult(
        Failure(FailureKind.cancelled, 'The native map has been released.'),
      );
    }
    try {
      final value = await run();
      if (_closed) {
        return const FailureResult(
          Failure(FailureKind.cancelled, 'The native map has been released.'),
        );
      }
      return Success(value);
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Native map ${operation.name} failed.',
        name: 'map.renderer',
        error: error,
        stackTrace: stackTrace,
      );
      if (!_closed) {
        if (operation == MapNativeOperation.sources) {
          _applied = MapRenderBaseline(camera: _applied.camera);
        }
        if (operation != MapNativeOperation.query) {
          _statuses.add(MapRenderStatus.renderingFailure);
        }
      }
      return const FailureResult(
        Failure(FailureKind.unexpected, 'The native map operation failed.'),
      );
    }
  }

  Future<void> close() {
    _styleTimeout?.cancel();
    _pending = null;
    return _statuses.close();
  }
}
