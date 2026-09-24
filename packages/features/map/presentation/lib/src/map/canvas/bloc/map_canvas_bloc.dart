import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_event.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_state.dart';
import 'package:map_presentation/src/map/canvas/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/canvas/models/map_canvas_failure.dart';
import 'package:map_presentation/src/map/canvas/models/map_canvas_status.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_libre_surface_factory.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_surface.dart';
import 'package:map_presentation/src/map/models/place_details.dart';
import 'package:synchronized/synchronized.dart';

/// Coordinates one canvas. It does not fetch data or request permissions.
@injectable
class MapCanvasBloc extends Bloc<MapCanvasEvent, MapCanvasState> {
  MapCanvasBloc(this._surfaceFactory) : super(const MapCanvasState()) {
    on<MapCanvasAttached>(_onAttached);
    on<MapCanvasStyleLoaded>(_onStyleLoaded);
    on<MapCanvasStyleReloadRequested>(_onStyleReloadRequested);
    on<MapCanvasStyleTimedOut>(_onStyleTimedOut);
    on<MapCanvasContentChanged>(_onContentChanged);
    on<MapCanvasTapped>(_onTapped);
    on<MapCanvasSelectionCleared>(_onSelectionCleared);
    on<MapCanvasFocusRequested>(_onFocusRequested);
    on<MapCanvasZoomRequested>(_onZoomRequested);
  }
  final MapLibreSurfaceFactory _surfaceFactory;
  final _canvasLock = Lock();
  MapSurface? _surface;
  Timer? _styleTimeout;

  MapSurface? get _readySurface {
    final surface = _surface;
    return state.ready && surface != null && !surface.isDisposed
        ? surface
        : null;
  }

  Future<void> _onAttached(
    MapCanvasAttached event,
    Emitter<MapCanvasState> emit,
  ) => _withCanvasLock(emit, () async {
    _surface = _surfaceFactory.create(event.controller);
    _beginStyleLoad(emit);
  });

  void _beginStyleLoad(Emitter<MapCanvasState> emit) {
    _styleTimeout?.cancel();
    emit(state.copyWith(status: MapCanvasStatus.loadingStyle, failure: null));
    _styleTimeout = Timer(const Duration(seconds: 25), () {
      if (!isClosed) add(const MapCanvasStyleTimedOut());
    });
  }

  Future<void> _onStyleLoaded(
    MapCanvasStyleLoaded event,
    Emitter<MapCanvasState> emit,
  ) => _withCanvasLock(emit, () async {
    final surface = _surface;
    if (surface == null || surface.isDisposed) return;
    _styleTimeout?.cancel();
    if (state.content.layer case final layer?) await surface.showPlaces(layer);
    if (emit.isDone || _surface != surface || surface.isDisposed) return;
    if (state.content.location case final location?) {
      await surface.showLocation(location);
    }
    if (emit.isDone || _surface != surface || surface.isDisposed) return;
    await _applyCameraFocus(surface);
    if (!emit.isDone && _surface == surface && !surface.isDisposed) {
      emit(state.copyWith(status: MapCanvasStatus.ready, failure: null));
    }
  });

  Future<void> _onStyleReloadRequested(
    MapCanvasStyleReloadRequested event,
    Emitter<MapCanvasState> emit,
  ) => _withCanvasLock(emit, () async {
    final surface = _surface;
    if (surface == null || surface.isDisposed) return;
    _beginStyleLoad(emit);
    await surface.reloadStyle();
  });

  Future<void> _onStyleTimedOut(
    MapCanvasStyleTimedOut event,
    Emitter<MapCanvasState> emit,
  ) => _withCanvasLock(emit, () async {
    // An expired timer's event can be queued behind a newer reload operation.
    if (state.status == MapCanvasStatus.loadingStyle &&
        _styleTimeout?.isActive == false) {
      emit(
        state.copyWith(
          status: MapCanvasStatus.failed,
          failure: MapCanvasFailure.styleTimeout,
        ),
      );
    }
  });

  Future<void> _onContentChanged(
    MapCanvasContentChanged event,
    Emitter<MapCanvasState> emit,
  ) => _withCanvasLock(emit, () async {
    final previous = state.content;
    final content = event.content;
    emit(
      state.copyWith(
        content: content,
        selected: previous.layer == content.layer ? state.selected : null,
      ),
    );
    final surface = _readySurface;
    if (surface == null) return;
    if (content.layer != previous.layer && content.layer != null) {
      await surface.showPlaces(content.layer!);
      if (emit.isDone || _surface != surface || surface.isDisposed) return;
      if (state.focus == MapCameraFocus.places) {
        await surface.fitPlaces(content.layer!);
      }
    }
    if (emit.isDone || _surface != surface || surface.isDisposed) return;
    if (content.location != previous.location && content.location != null) {
      await surface.showLocation(content.location!);
      if (emit.isDone || _surface != surface || surface.isDisposed) return;
      if (state.focus == MapCameraFocus.userLocation) {
        await surface.centerOn(content.location!);
      }
    }
  });

  Future<void> _onTapped(MapCanvasTapped event, Emitter<MapCanvasState> emit) =>
      _withCanvasLock(emit, () async {
        final surface = _readySurface;
        if (surface == null) return;
        final id = await surface.placeAt(event.point);
        if (emit.isDone || _surface != surface || surface.isDisposed) return;
        final place = state.content.layer?.places
            .where((place) => place.id == id)
            .firstOrNull;
        emit(
          state.copyWith(
            selected: place == null ? null : PlaceDetails.fromPlace(place),
          ),
        );
      });

  Future<void> _onSelectionCleared(
    MapCanvasSelectionCleared event,
    Emitter<MapCanvasState> emit,
  ) => _withCanvasLock(emit, () async {
    emit(state.copyWith(selected: null));
  });

  Future<void> _onFocusRequested(
    MapCanvasFocusRequested event,
    Emitter<MapCanvasState> emit,
  ) => _withCanvasLock(emit, () async {
    emit(state.copyWith(focus: event.focus));
    final surface = _readySurface;
    if (surface != null) await _applyCameraFocus(surface);
  });

  Future<void> _applyCameraFocus(MapSurface surface) async {
    switch (state.focus) {
      case MapCameraFocus.places:
        if (state.content.layer case final layer?) {
          await surface.fitPlaces(layer);
        }
      case MapCameraFocus.userLocation:
        if (state.content.location case final location?) {
          await surface.centerOn(location);
        }
    }
  }

  Future<void> _onZoomRequested(
    MapCanvasZoomRequested event,
    Emitter<MapCanvasState> emit,
  ) => _withCanvasLock(emit, () async {
    await _readySurface?.zoomBy(event.amount);
  });

  // Different typed handlers share one native canvas. A lock serializes their
  // operations across event types; per-handler sequential() would not do that.
  Future<void> _withCanvasLock(
    Emitter<MapCanvasState> emit,
    Future<void> Function() operation,
  ) => _canvasLock.synchronized(() async {
    if (isClosed || emit.isDone) return;
    try {
      await operation();
    } on Exception {
      if (!emit.isDone && _surface != null) {
        emit(
          state.copyWith(
            status: MapCanvasStatus.failed,
            failure: MapCanvasFailure.rendering,
          ),
        );
      }
    }
  });

  @override
  Future<void> close() {
    _styleTimeout?.cancel();
    _surface = null;
    return super.close();
  }
}
