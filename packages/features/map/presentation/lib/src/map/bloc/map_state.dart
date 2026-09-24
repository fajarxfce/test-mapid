import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:map_presentation/src/map/models/location_action.dart';
import 'package:map_presentation/src/map/models/place_details.dart';
part 'map_state.freezed.dart';

@freezed
abstract class MapState with _$MapState {
  const MapState._();
  const factory MapState({
    @Default(true) bool loadingLayer,
    @Default(false) bool locating,
    @Default(false) bool styleReady,
    @Default(0) int placeCount,
    @Default('Pariwisata Jogja') String layerName,
    String? layerError,
    String? mapError,
    String? locationMessage,
    @Default(LocationAction.locate) LocationAction locationAction,
    PlaceDetails? selected,
  }) = _MapState;

  String get layerCaption => loadingLayer
      ? 'Memuat data GEO MAPID…'
      : placeCount == 0
      ? 'Belum ada tempat pada layer ini'
      : '$placeCount tempat untuk dijelajahi';
  String get locationLabel => switch (locationAction) {
    LocationAction.locate => 'Lokasi saya',
    LocationAction.appSettings => 'Buka izin aplikasi',
    LocationAction.deviceSettings => 'Aktifkan GPS',
  };
}
