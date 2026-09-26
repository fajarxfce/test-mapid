import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/bloc/map_effect.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';
import 'package:map_presentation/src/map/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/models/place_details.dart';

/// Owns page state and user intent. The route owns the native renderer.
@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(this._loadLayer, this._watchLocation, this._openSettings)
    : super(const MapState()) {
    on<MapCanvasStatusChanged>(_onCanvasStatusChanged);
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
    on<MapCanvasRetryRequested>(_onCanvasRetryRequested);
    on<MapPlaceSelected>(_onPlaceSelected);
    on<MapSelectionCleared>(_onSelectionCleared);
    on<MapFocusRequested>(_onFocusRequested);
    on<MapZoomRequested>(_onZoomRequested);
    on<MapPanned>(_onPanned);
  }

  final LoadMapLayer _loadLayer;
  final WatchLocation _watchLocation;
  final OpenLocationSettings _openSettings;
  final _effects = StreamController<MapEffect>.broadcast();
  Stream<MapEffect> get effects => _effects.stream;

  void _onCanvasStatusChanged(
    MapCanvasStatusChanged event,
    Emitter<MapState> emit,
  ) => emit(state.copyWith(canvasStatus: event.status));

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
            layer: value,
            loadingLayer: false,
            selected: state.layer == value
                ? state.selected
                : value.places
                      .where((place) => place.id == state.selected?.id)
                      .map(PlaceDetails.fromPlace)
                      .firstOrNull,
          ),
        );
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
            return state.copyWith(
              location: value,
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
    _effects.add(const FocusMapCamera(MapCameraFocus.userLocation));
    if (state.locationAction == LocationAction.locate) {
      add(const MapLocationRequested());
      return;
    }
    final recoveryFailure = state.locationFailure;
    final result = await _openSettings(
      state.locationAction == LocationAction.appSettings
          ? LocationSettingsTarget.application
          : LocationSettingsTarget.device,
    );
    if (emit.isDone ||
        state.locationStatus != LocationTrackingStatus.failed ||
        state.locationFailure != recoveryFailure) {
      return;
    }
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

  void _onCanvasRetryRequested(
    MapCanvasRetryRequested event,
    Emitter<MapState> emit,
  ) => _effects.add(const ReloadMapCanvas());

  void _onPlaceSelected(MapPlaceSelected event, Emitter<MapState> emit) => emit(
    state.copyWith(
      selected: state.layer?.places
          .where((place) => place.id == event.id)
          .map(PlaceDetails.fromPlace)
          .firstOrNull,
    ),
  );

  void _onSelectionCleared(MapSelectionCleared event, Emitter<MapState> emit) =>
      emit(state.copyWith(selected: null));

  void _onFocusRequested(MapFocusRequested event, Emitter<MapState> emit) =>
      _effects.add(FocusMapCamera(event.focus));

  void _onZoomRequested(MapZoomRequested event, Emitter<MapState> emit) =>
      _effects.add(ZoomMapCamera(event.amount));

  void _onPanned(MapPanned event, Emitter<MapState> emit) =>
      _effects.add(const FocusMapCamera(MapCameraFocus.free));

  @override
  Future<void> close() async {
    await super.close();
    await _effects.close();
  }
}
