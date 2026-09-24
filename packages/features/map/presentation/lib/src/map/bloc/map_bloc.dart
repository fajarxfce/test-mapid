import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core_common/core_common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';
import 'package:map_presentation/src/map/models/location_action.dart';
import 'package:map_presentation/src/map/models/place_details.dart';
import 'package:map_presentation/src/map/rendering/map_libre_renderer.dart';

@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(this._loadLayer, this._locateUser, this._openSettings, this._renderer)
    : super(const MapState()) {
    on<MapLayerRequested>(_onLayerRequested, transformer: restartable());
    on<MapLocationRequested>(_onLocationRequested, transformer: droppable());
    on<MapLocationSettingsRequested>(
      _onSettingsRequested,
      transformer: droppable(),
    );
    on<MapSceneEvent>(_onSceneEvent, transformer: sequential());
  }
  final LoadMapLayer _loadLayer;
  final LocateUser _locateUser;
  final OpenLocationSettings _openSettings;
  final MapLibreRenderer _renderer;
  MapLayer? _layer;
  UserLocation? _location;
  Timer? _styleTimeout;
  bool _focusUser = false;

  Future<void> _onLayerRequested(
    MapLayerRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(loadingLayer: true, layerError: null));
    final result = await _loadLayer();
    if (!emit.isDone && !isClosed) add(MapLayerReceived(result));
  }

  Future<void> _onLocationRequested(
    MapLocationRequested event,
    Emitter<MapState> emit,
  ) async {
    _focusUser = event.focus;
    emit(state.copyWith(locating: true, locationMessage: null));
    final result = await _locateUser();
    if (!emit.isDone && !isClosed) {
      add(MapLocationReceived(result, focus: event.focus));
    }
  }

  Future<void> _onSettingsRequested(
    MapLocationSettingsRequested event,
    Emitter<MapState> emit,
  ) async {
    if (state.locationAction == LocationAction.locate) {
      add(const MapLocationRequested());
      return;
    }
    try {
      final opened = await _openSettings(
        state.locationAction == LocationAction.appSettings
            ? LocationSettingsTarget.application
            : LocationSettingsTarget.device,
      );
      if (emit.isDone) return;
      emit(
        state.copyWith(
          locationAction: LocationAction.locate,
          locationMessage: opened
              ? 'Setelah mengaktifkan lokasi, ketuk Lokasi saya.'
              : 'Buka pengaturan lokasi perangkat, lalu coba lagi.',
        ),
      );
    } on Exception {
      if (!emit.isDone) {
        emit(
          state.copyWith(
            locationMessage: 'Pengaturan tidak dapat dibuka. Buka pengaturan perangkat secara manual.',
          ),
        );
      }
    }
  }

  Future<void> _onSceneEvent(
    MapSceneEvent event,
    Emitter<MapState> emit,
  ) async {
    try {
      switch (event) {
        case MapAttached(:final controller):
          _renderer.attach(controller);
          _startStyleTimeout();
        case MapStyleLoaded():
          _styleTimeout?.cancel();
          emit(state.copyWith(styleReady: true, mapError: null));
          if (_layer case final layer?) await _renderer.renderLayer(layer);
          if (_location case final location?) {
            await _renderer.renderLocation(location);
          }
          if (_focusUser && _location != null) {
            await _renderer.focusLocation(_location!);
          } else if (_layer != null) {
            await _renderer.fitLayer(_layer!);
          }
        case MapStyleTimedOut():
          if (!state.styleReady) {
            emit(
              state.copyWith(
                mapError: 'Basemap belum dapat dimuat. Periksa koneksi internet lalu coba lagi.',
              ),
            );
          }
        case MapStyleReloadRequested():
          emit(state.copyWith(styleReady: false, mapError: null));
          _startStyleTimeout();
          await _renderer.reloadStyle();
        case MapLayerReceived(:final result):
          switch (result) {
            case Success(:final value):
              _layer = value;
              emit(
                state.copyWith(
                  loadingLayer: false,
                  layerError: null,
                  layerName: value.name,
                  placeCount: value.places.length,
                  selected: null,
                ),
              );
              if (state.styleReady) {
                await _renderer.renderLayer(value);
                if (!_focusUser) await _renderer.fitLayer(value);
              }
            case FailureResult(:final failure):
              emit(
                state.copyWith(
                  loadingLayer: false,
                  layerError: _layerFailureMessage(failure.kind),
                ),
              );
          }
        case MapLocationReceived(:final result, :final focus):
          switch (result) {
            case Success(:final value):
              _location = value;
              emit(
                state.copyWith(
                  locating: false,
                  locationAction: LocationAction.locate,
                  locationMessage:
                      'Lokasi ditemukan · akurasi ±${value.accuracyMeters.toStringAsFixed(0)} m',
                ),
              );
              if (state.styleReady) {
                await _renderer.renderLocation(value);
                if (focus && _focusUser) await _renderer.focusLocation(value);
              }
            case FailureResult(:final failure):
              emit(
                state.copyWith(
                  locating: false,
                  locationMessage: failure.message,
                  locationAction: switch (failure.kind) {
                    FailureKind.permissionPermanentlyDenied =>
                      LocationAction.appSettings,
                    FailureKind.serviceDisabled =>
                      LocationAction.deviceSettings,
                    _ => LocationAction.locate,
                  },
                ),
              );
          }
        case MapTapped(:final point):
          if (!state.styleReady || _layer == null) return;
          final id = await _renderer.placeAt(point);
          final place = _layer!.places
              .where((place) => place.id == id)
              .firstOrNull;
          if (!emit.isDone) {
            emit(
              state.copyWith(
                selected: place == null ? null : PlaceDetails.fromPlace(place),
              ),
            );
          }
        case MapSelectionCleared():
          emit(state.copyWith(selected: null));
        case MapLayerFocusRequested():
          _focusUser = false;
          if (state.styleReady && _layer != null) {
            await _renderer.fitLayer(_layer!);
          }
        case MapZoomRequested(:final amount):
          if (state.styleReady) await _renderer.zoom(amount);
      }
    } on Exception {
      if (!emit.isDone) {
        emit(
          state.copyWith(
            mapError: 'Peta belum dapat diperbarui. Coba muat ulang basemap.',
          ),
        );
      }
    }
  }

  void _startStyleTimeout() {
    _styleTimeout?.cancel();
    _styleTimeout = Timer(const Duration(seconds: 25), () {
      if (!isClosed) add(const MapStyleTimedOut());
    });
  }

  String _layerFailureMessage(FailureKind kind) => switch (kind) {
    FailureKind.unauthorized || FailureKind.forbidden =>
      'Akses layer ditolak. Periksa API key dan izin layer GEO MAPID.',
    FailureKind.network || FailureKind.timeout =>
      'Data wisata belum dapat dimuat. Periksa koneksi internet dan coba lagi.',
    FailureKind.invalidResponse => 'Format data layer belum dapat dibaca.',
    _ => 'Layanan GEO MAPID belum dapat diakses. Coba lagi sebentar.',
  };

  @override
  Future<void> close() {
    _styleTimeout?.cancel();
    _renderer.detach();
    return super.close();
  }
}
