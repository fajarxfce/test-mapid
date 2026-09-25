import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';
import 'package:map_presentation/src/map/models/map_scene.dart';
import 'package:map_presentation/src/map/models/place_details.dart';
import 'package:map_presentation/src/map/rendering/map_renderer.dart';

/// Owns page state and user intent. The route owns the native renderer.
@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(
    this._loadLayer,
    this._watchLocation,
    this._openSettings,
    @factoryParam this._renderer,
  ) : super(const MapState()) {
    on<MapStarted>(_onStarted, transformer: droppable());
    on<MapLayerRequested>(_onLayerRequested, transformer: restartable());
    on<MapLocationRequested>(
      _onLocationRequested,
      transformer: (events, mapper) => restartable<MapLocationRequested>()(
        events.where(
          (_) =>
              !state.locating &&
              state.locationStatus != LocationTrackingStatus.live,
        ),
        mapper,
      ),
    );
    on<MapLocationActionRequested>(
      _onLocationActionRequested,
      transformer: droppable(),
    );
    on<MapStyleReloadRequested>(_onStyleReloadRequested);
    on<MapTapped>(_onTapped, transformer: restartable());
    on<MapSelectionCleared>(_onSelectionCleared);
    on<MapFocusRequested>(_onFocusRequested);
    on<MapZoomRequested>(_onZoomRequested);
    on<MapPanned>(_onPanned);
  }

  final LoadMapLayer _loadLayer;
  final WatchLocation _watchLocation;
  final OpenLocationSettings _openSettings;
  final MapRenderer _renderer;

  Future<void> _onStarted(MapStarted event, Emitter<MapState> emit) =>
      emit.forEach(
        _renderer.statuses,
        onData: (status) => state.copyWith(renderStatus: status),
      );

  Future<void> _onLayerRequested(
    MapLayerRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(loadingLayer: true, layerFailure: null));
    final result = await _loadLayer();
    if (emit.isDone) return;
    switch (result) {
      case Success(:final value):
        emit(
          state.copyWith(
            scene: state.scene.copyWith(layer: value),
            loadingLayer: false,
            selected: state.scene.layer == value
                ? state.selected
                : value.places
                      .where((place) => place.id == state.selected?.id)
                      .map(PlaceDetails.fromPlace)
                      .firstOrNull,
          ),
        );
        _renderer.render(state.scene);
      case FailureResult(:final failure):
        emit(state.copyWith(loadingLayer: false, layerFailure: failure));
    }
  }

  Future<void> _onLocationRequested(
    MapLocationRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(
      state.copyWith(
        locationStatus: LocationTrackingStatus.acquiring,
        locationFailure: null,
        settingsMessage: null,
      ),
    );
    await emit.forEach(
      _watchLocation(),
      onData: (result) {
        switch (result) {
          case Success(:final value):
            final scene = state.scene.copyWith(location: value);
            _renderer.render(scene);
            return state.copyWith(
              scene: scene,
              locationStatus: LocationTrackingStatus.live,
              locationFailure: null,
              settingsMessage: null,
            );
          case FailureResult(:final failure):
            return state.copyWith(
              locationStatus: failure.kind == FailureKind.cancelled
                  ? LocationTrackingStatus.paused
                  : LocationTrackingStatus.failed,
              locationFailure: failure.kind == FailureKind.cancelled
                  ? null
                  : failure,
            );
        }
      },
    );
  }

  Future<void> _onLocationActionRequested(
    MapLocationActionRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(
      state.copyWith(
        scene: state.scene.copyWith(focus: MapCameraFocus.userLocation),
      ),
    );
    _renderer.focus(state.scene);
    if (state.locationAction == LocationAction.locate) {
      add(const MapLocationRequested());
      return;
    }
    final result = await _openSettings(
      state.locationAction == LocationAction.appSettings
          ? LocationSettingsTarget.application
          : LocationSettingsTarget.device,
    );
    if (emit.isDone) return;
    emit(
      state.copyWith(
        settingsMessage: switch (result) {
          Success() => null,
          FailureResult() =>
            'Buka pengaturan lokasi perangkat, lalu coba lagi.',
        },
      ),
    );
  }

  void _onStyleReloadRequested(
    MapStyleReloadRequested event,
    Emitter<MapState> emit,
  ) => _renderer.reloadStyle();

  Future<void> _onTapped(MapTapped event, Emitter<MapState> emit) {
    final layerAtTap = state.scene.layer;
    final selectionAtTap = state.selected;
    return emit.forEach(
      _renderer.placeAt(event.point).asStream(),
      onData: (result) {
        // A dismissed popup or replaced dataset invalidates the pending pick.
        if (state.scene.layer != layerAtTap ||
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

  void _onSelectionCleared(MapSelectionCleared event, Emitter<MapState> emit) =>
      emit(state.copyWith(selected: null));

  void _onFocusRequested(MapFocusRequested event, Emitter<MapState> emit) {
    emit(state.copyWith(scene: state.scene.copyWith(focus: event.focus)));
    _renderer.focus(state.scene);
  }

  void _onZoomRequested(MapZoomRequested event, Emitter<MapState> emit) =>
      _renderer.zoomBy(event.amount);

  void _onPanned(MapPanned event, Emitter<MapState> emit) {
    if (state.scene.focus == MapCameraFocus.free) return;
    emit(
      state.copyWith(scene: state.scene.copyWith(focus: MapCameraFocus.free)),
    );
    _renderer.render(state.scene);
  }
}
