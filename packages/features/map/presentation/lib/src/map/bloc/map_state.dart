import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/models/location_action.dart';
import 'package:map_presentation/src/map/models/map_content.dart';

part 'map_state.freezed.dart';

@freezed
abstract class MapState with _$MapState {
  const MapState._();
  const factory MapState({
    MapLayer? layer,
    LocationFix? location,
    @Default(true) bool loadingLayer,
    @Default(false) bool locating,
    Failure? layerFailure,
    Failure? locationFailure,
    String? settingsMessage,
  }) = _MapState;

  MapContent get content => MapContent(layer: layer, location: location);
  String get layerName => layer?.name ?? 'Pariwisata Jogja';
  int get placeCount => layer?.places.length ?? 0;
  String get layerCaption => loadingLayer
      ? 'Memuat data GEO MAPID…'
      : placeCount == 0
      ? 'Belum ada tempat pada layer ini'
      : '$placeCount tempat untuk dijelajahi';

  String? get layerError => switch (layerFailure?.kind) {
    null => null,
    FailureKind.unauthorized || FailureKind.forbidden =>
      'Akses layer ditolak. Periksa API key dan izin layer GEO MAPID.',
    FailureKind.network || FailureKind.timeout =>
      'Data wisata belum dapat dimuat. Periksa koneksi internet dan coba lagi.',
    FailureKind.invalidResponse => 'Format data layer belum dapat dibaca.',
    _ => 'Layanan GEO MAPID belum dapat diakses. Coba lagi sebentar.',
  };

  LocationAction get locationAction => switch (locationFailure?.kind) {
    FailureKind.permissionPermanentlyDenied => LocationAction.appSettings,
    FailureKind.serviceDisabled => LocationAction.deviceSettings,
    _ => LocationAction.locate,
  };

  String get locationLabel => switch (locationAction) {
    LocationAction.locate => 'Lokasi saya',
    LocationAction.appSettings => 'Buka izin aplikasi',
    LocationAction.deviceSettings => 'Aktifkan GPS',
  };

  String? get locationMessage => locating
      ? null
      : settingsMessage ??
            switch (locationFailure?.kind) {
              null =>
                location == null
                    ? null
                    : 'Lokasi ditemukan · akurasi ±${location!.accuracyMeters.toStringAsFixed(0)} m',
              FailureKind.permissionDenied => 'Izin lokasi belum diberikan. Peta wisata tetap bisa digunakan.',
              FailureKind.permissionPermanentlyDenied =>
                'Izin lokasi perlu diaktifkan melalui pengaturan aplikasi.',
              FailureKind.serviceDisabled =>
                'Aktifkan GPS untuk menampilkan lokasi kamu.',
              FailureKind.timeout =>
                'Lokasi belum ditemukan. Coba lagi di area terbuka.',
              _ => 'Lokasi perangkat belum dapat diakses. Coba lagi.',
            };
}
