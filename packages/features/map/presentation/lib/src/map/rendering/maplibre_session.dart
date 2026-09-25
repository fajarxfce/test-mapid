import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:core_common/core_common.dart';
import 'package:map_presentation/src/map/canvas/models/map_scene.dart';
import 'package:map_presentation/src/map/rendering/map_render_plan.dart';
import 'package:map_presentation/src/map/rendering/map_renderer.dart';
import 'package:map_presentation/src/map/rendering/maplibre_camera.dart';
import 'package:map_presentation/src/map/rendering/maplibre_layers.dart';
import 'package:maplibre_gl/maplibre_gl.dart' show MapLibreMapController;
import 'package:synchronized/synchronized.dart';

/// Owns operations for exactly one native controller. The widget disposes it.
final class MapLibreSession {
  MapLibreSession(this._controller, {required this.styleUrl})
    : _layers = MapLibreLayers(_controller),
      _camera = MapLibreCamera(_controller) {
    _waitForStyle();
  }

  final MapLibreMapController _controller;
  final String styleUrl;
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
          await _execute(_NativeOperation.camera, () => _camera.zoomBy(amount));
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
          _NativeOperation.style,
          () => _controller.setStyle(styleUrl),
        ),
      ),
    );
  }

  Future<Result<String?>> placeAt(Point<double> point) =>
      _operations.synchronized(
        () => _execute(
          _NativeOperation.query,
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
    for (final change in diffMapScene(
      _applied,
      scene,
    ).where((change) => change is! MapCameraChanged)) {
      if (!await _apply(change)) return;
    }

    // Read current intent after I/O, including a pan or a newer GPS fix.
    // Camera progress must not wait for a continuous sensor stream to become idle.
    final pending = _pending;
    final target = pending?.scene ?? scene;
    final focusRequested = pending == null
        ? refocus
        : pending.refocus || (refocus && pending.scene.focus == scene.focus);
    if (pending != null) _pending = (scene: pending.scene, refocus: false);
    for (final change in diffMapScene(
      _applied,
      target,
      refocus: focusRequested,
    ).whereType<MapCameraChanged>()) {
      if (!await _apply(change)) return;
    }
    if (!_closed && _styleReady) _statuses.add(MapRenderStatus.ready);
  }

  Future<bool> _apply(MapSceneChange change) async {
    if (_closed || !_styleReady) return false;
    final result = await switch (change) {
      MapPlacesChanged(:final layer) => _execute(
        _NativeOperation.sources,
        () => _layers.showPlaces(layer),
      ),
      MapLocationChanged(:final location) => _execute(
        _NativeOperation.sources,
        () => _layers.showLocation(location),
      ),
      MapCameraChanged(:final scene, :final reframe) => _execute(
        _NativeOperation.camera,
        () => _camera.focus(scene, reframe: reframe),
      ),
    };
    if (_closed || !_styleReady || result is FailureResult<void>) return false;
    _applied = _applied.afterSuccess(change);
    return true;
  }

  Future<Result<T>> _execute<T>(
    _NativeOperation operation,
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
        if (operation == _NativeOperation.sources) {
          _applied = MapRenderBaseline(camera: _applied.camera);
        }
        if (operation != _NativeOperation.query) {
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

enum _NativeOperation { sources, camera, query, style }
