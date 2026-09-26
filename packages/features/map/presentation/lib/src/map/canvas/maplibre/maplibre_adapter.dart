import 'dart:async';
import 'dart:developer' as developer;

import 'package:core_location_domain/core_location_domain.dart';
import 'package:injectable/injectable.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/canvas/map_canvas_port.dart';
import 'package:map_presentation/src/map/canvas/maplibre/location_marker.dart';
import 'package:map_presentation/src/map/canvas/maplibre/map_camera.dart';
import 'package:map_presentation/src/map/canvas/maplibre/tourism_markers.dart';
import 'package:map_presentation/src/map/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/models/map_canvas_status.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

/// Owns canvas readiness and orders native work. Components own their updates.
@injectable
final class MapLibreAdapter implements MapCanvasPort {
  MapLibreAdapter() {
    _waitFor(MapCanvasStatus.waitingForMap, MapCanvasStatus.creationTimeout);
  }

  static const styleUrl = 'https://tiles.openfreemap.org/styles/liberty';
  final _statuses = BehaviorSubject.seeded(MapCanvasStatus.waitingForMap);
  final _selections = StreamController<String?>.broadcast();
  final _camera = MapCamera();
  MapLibreMapController? _controller;
  _MapAnnotations? _annotations;
  MapLayer? _layer;
  LocationFix? _location;
  Lock _operations = Lock();
  Timer? _deadline;
  bool _styleReady = false;
  bool _updateScheduled = false;

  @override
  Stream<MapCanvasStatus> get statuses => _statuses.stream.distinct();
  @override
  Stream<String?> get selections => _selections.stream;

  void attach(MapLibreMapController controller) {
    if (_statuses.isClosed ||
        controller.isDisposed ||
        _statuses.value == MapCanvasStatus.creationTimeout) {
      return;
    }
    _controller?.onCircleTapped.remove(_onCircleTapped);
    _annotations?.close();
    _controller = controller;
    _annotations = null;
    // A replacement controller must not wait on its predecessor's pending I/O.
    _operations = Lock();
    _updateScheduled = false;
    _camera.attach(controller);
    controller.onCircleTapped.add(_onCircleTapped);
    _waitFor(MapCanvasStatus.loadingStyle, MapCanvasStatus.styleTimeout);
  }

  void styleLoaded() {
    final controller = _controller;
    if (_statuses.isClosed || controller == null || controller.isDisposed) {
      return;
    }
    _deadline?.cancel();
    _annotations?.close();
    _annotations = _MapAnnotations(controller);
    _camera.resetStyle();
    _styleReady = true;
    _scheduleUpdate();
  }

  @override
  void showPlaces(MapLayer? layer) {
    _layer = layer;
    _scheduleUpdate();
  }

  @override
  void updateLocation(LocationFix? location) {
    _location = location;
    _scheduleUpdate();
  }

  @override
  void focus(MapCameraFocus focus) {
    if (_statuses.isClosed) return;
    _camera.requestFocus(focus, waitForCommand: _styleReady);
    if (!_styleReady || focus == MapCameraFocus.free) return;
    final annotations = _annotations;
    unawaited(
      _operations.synchronized(
        () => _runNative(
          'camera focus',
          annotations,
          () => _camera.applyFocus(focus, _layer, _location),
        ),
      ),
    );
  }

  @override
  void zoomBy(double amount) {
    final annotations = _annotations;
    unawaited(
      _operations.synchronized(
        () => _runNative('camera zoom', annotations, () async {
          await _camera.zoomBy(amount);
        }),
      ),
    );
  }

  void _scheduleUpdate() {
    if (_statuses.isClosed || !_styleReady || _updateScheduled) return;
    _updateScheduled = true;
    final queue = _operations;
    unawaited(
      queue.synchronized(() async {
        final annotations = _annotations;
        final layer = _layer;
        final location = _location;
        try {
          if (!await _runNative(
            'tourism markers',
            annotations,
            () => annotations!.places.show(layer),
          )) {
            return;
          }
          if (!await _runNative(
            'location marker',
            annotations,
            () => annotations!.location.show(location),
          )) {
            return;
          }
          // Sensor input can advance during native I/O. Read current camera intent.
          if (await _runNative(
            'camera follow',
            annotations,
            () => _camera.update(_layer, _location),
          )) {
            _statuses.add(MapCanvasStatus.ready);
          }
        } finally {
          if (identical(queue, _operations)) {
            _updateScheduled = false;
            if (_layer != layer ||
                _location != location ||
                !identical(annotations, _annotations)) {
              _scheduleUpdate();
            }
          }
        }
      }),
    );
  }

  Future<bool> _runNative(
    String operation,
    _MapAnnotations? annotations,
    Future<void> Function() run,
  ) async {
    if (_statuses.isClosed ||
        !_styleReady ||
        annotations == null ||
        !identical(annotations, _annotations) ||
        _controller!.isDisposed) {
      return false;
    }
    try {
      await run();
      if (_statuses.isClosed ||
          !_styleReady ||
          !identical(annotations, _annotations)) {
        return false;
      }
      return true;
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Native $operation failed.',
        name: 'map.canvas',
        error: error,
        stackTrace: stackTrace,
      );
      if (!_statuses.isClosed &&
          _styleReady &&
          identical(annotations, _annotations)) {
        _statuses.add(MapCanvasStatus.renderingFailure);
      }
      return false;
    }
  }

  void _onCircleTapped(Circle circle) {
    if (_statuses.isClosed || !_styleReady) return;
    final id = _annotations?.places.placeId(circle);
    if (id != null) _selections.add(id);
  }

  void backgroundTapped() {
    if (!_statuses.isClosed && _styleReady) _selections.add(null);
  }

  @override
  void retry() {
    if (_statuses.isClosed) return;
    final controller = _controller;
    if (controller == null) {
      _waitFor(MapCanvasStatus.waitingForMap, MapCanvasStatus.creationTimeout);
      return;
    }
    _annotations?.close();
    _waitFor(MapCanvasStatus.loadingStyle, MapCanvasStatus.styleTimeout);
    unawaited(
      _operations.synchronized(() async {
        if (_statuses.isClosed ||
            !identical(controller, _controller) ||
            controller.isDisposed) {
          return;
        }
        try {
          await controller.setStyle(styleUrl);
        } on Exception catch (error, stackTrace) {
          developer.log(
            'Native style reload failed.',
            name: 'map.canvas',
            error: error,
            stackTrace: stackTrace,
          );
          if (!_statuses.isClosed && identical(controller, _controller)) {
            _deadline?.cancel();
            _statuses.add(MapCanvasStatus.renderingFailure);
          }
        }
      }),
    );
  }

  void _waitFor(MapCanvasStatus waiting, MapCanvasStatus timeout) {
    _styleReady = false;
    _deadline?.cancel();
    _statuses.add(waiting);
    _deadline = Timer(const Duration(seconds: 25), () {
      if (!_statuses.isClosed) _statuses.add(timeout);
    });
  }

  /// The SDK widget disposes its controller; the route disposes this adapter.
  @override
  Future<void> close() async {
    if (_statuses.isClosed) return;
    _deadline?.cancel();
    _controller?.onCircleTapped.remove(_onCircleTapped);
    _annotations?.close();
    _camera.close();
    await Future.wait([_statuses.close(), _selections.close()]);
  }
}

/// Annotation handles belong to one loaded style and are released together.
final class _MapAnnotations {
  _MapAnnotations(MapLibreMapController controller)
    : places = TourismMarkers(controller),
      location = LocationMarker(controller);
  final TourismMarkers places;
  final LocationMarker location;
  void close() {
    places.close();
    location.close();
  }
}
