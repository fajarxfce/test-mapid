import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core_common/core_common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_event.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_state.dart';
import 'package:map_presentation/src/map/canvas/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_renderer.dart';
import 'package:map_presentation/src/map/models/place_details.dart';

/// Owns user intent and selection. The renderer owns native resources and work.
@injectable
class MapCanvasBloc extends Bloc<MapCanvasEvent, MapCanvasState> {
  MapCanvasBloc(this._renderer) : super(const MapCanvasState()) {
    on<MapCanvasAttached>(_onAttached, transformer: restartable());
    on<MapCanvasStyleLoaded>(_onStyleLoaded);
    on<MapCanvasStyleReloadRequested>(_onStyleReloadRequested);
    on<MapCanvasContentChanged>(_onContentChanged);
    on<MapCanvasTapped>(_onTapped, transformer: restartable());
    on<MapCanvasSelectionCleared>(_onSelectionCleared);
    on<MapCanvasFocusRequested>(_onFocusRequested);
    on<MapCanvasZoomRequested>(_onZoomRequested);
    on<MapCanvasPanned>(_onPanned);
  }
  final MapRenderer _renderer;

  void _onPanned(MapCanvasPanned event, Emitter<MapCanvasState> emit) {
    if (state.scene.focus == MapCameraFocus.free) return;
    emit(
      state.copyWith(scene: state.scene.copyWith(focus: MapCameraFocus.free)),
    );
    _renderer.render(state.scene);
  }

  Future<void> _onAttached(
    MapCanvasAttached event,
    Emitter<MapCanvasState> emit,
  ) => emit.forEach(
    _renderer.attach(event.controller),
    onData: (status) => state.copyWith(renderStatus: status),
  );

  void _onStyleLoaded(
    MapCanvasStyleLoaded event,
    Emitter<MapCanvasState> emit,
  ) => _renderer.styleLoaded();

  void _onStyleReloadRequested(
    MapCanvasStyleReloadRequested event,
    Emitter<MapCanvasState> emit,
  ) => _renderer.reloadStyle();

  void _onContentChanged(
    MapCanvasContentChanged event,
    Emitter<MapCanvasState> emit,
  ) {
    emit(
      state.copyWith(
        scene: state.scene.copyWith(content: event.content),
        selected: state.scene.content.layer == event.content.layer
            ? state.selected
            : null,
      ),
    );
    _renderer.render(state.scene);
  }

  Future<void> _onTapped(MapCanvasTapped event, Emitter<MapCanvasState> emit) {
    final layerAtTap = state.scene.content.layer;
    final selectionAtTap = state.selected;
    return emit.forEach(
      _renderer.placeAt(event.point).asStream(),
      onData: (result) {
        // A dismissed popup or a replaced dataset invalidates the pending pick.
        if (state.scene.content.layer != layerAtTap ||
            state.selected != selectionAtTap) {
          return state;
        }
        return switch (result) {
          Success(:final value) => state.copyWith(
            selected: layerAtTap?.places
                .where((place) => place.id == value)
                .map(PlaceDetails.fromPlace)
                .firstOrNull,
          ),
          FailureResult() => state,
        };
      },
    );
  }

  void _onSelectionCleared(
    MapCanvasSelectionCleared event,
    Emitter<MapCanvasState> emit,
  ) => emit(state.copyWith(selected: null));

  void _onFocusRequested(
    MapCanvasFocusRequested event,
    Emitter<MapCanvasState> emit,
  ) {
    emit(state.copyWith(scene: state.scene.copyWith(focus: event.focus)));
    _renderer.focus(state.scene);
  }

  void _onZoomRequested(
    MapCanvasZoomRequested event,
    Emitter<MapCanvasState> emit,
  ) => _renderer.zoomBy(event.amount);

  @override
  Future<void> close() async {
    await super.close();
    await _renderer.close();
  }
}
