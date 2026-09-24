import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';
import 'package:map_presentation/src/map/models/location_action.dart';

/// Loads screen data. Native map lifecycle and interaction belong to the canvas.
@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(this._loadLayer, this._getLocation, this._openSettings)
    : super(const MapState()) {
    on<MapLayerRequested>(_loadMapLayer, transformer: restartable());
    on<MapLocationRequested>(_getCurrentLocation, transformer: droppable());
    on<MapLocationActionRequested>(
      _handleLocationAction,
      transformer: droppable(),
    );
  }
  final LoadMapLayer _loadLayer;
  final GetCurrentLocation _getLocation;
  final OpenLocationSettings _openSettings;

  Future<void> _loadMapLayer(
    MapLayerRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(loadingLayer: true, layerFailure: null));
    final result = await _loadLayer();
    if (emit.isDone) return;
    emit(switch (result) {
      Success(:final value) => state.copyWith(
        layer: value,
        loadingLayer: false,
      ),
      FailureResult(:final failure) => state.copyWith(
        loadingLayer: false,
        layerFailure: failure,
      ),
    });
  }

  Future<void> _getCurrentLocation(
    MapLocationRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(
      state.copyWith(
        locating: true,
        locationFailure: null,
        settingsMessage: null,
      ),
    );
    final result = await _getLocation();
    if (emit.isDone) return;
    emit(switch (result) {
      Success(:final value) => state.copyWith(location: value, locating: false),
      FailureResult(:final failure) => state.copyWith(
        locating: false,
        locationFailure: failure,
      ),
    });
  }

  Future<void> _handleLocationAction(
    MapLocationActionRequested event,
    Emitter<MapState> emit,
  ) async {
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
        locationFailure: null,
        settingsMessage: switch (result) {
          Success() => 'Setelah mengaktifkan lokasi, ketuk Lokasi saya.',
          FailureResult() =>
            'Buka pengaturan lokasi perangkat, lalu coba lagi.',
        },
      ),
    );
  }
}
