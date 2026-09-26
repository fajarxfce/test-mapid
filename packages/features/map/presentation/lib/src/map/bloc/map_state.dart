import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/models/map_canvas_status.dart';
import 'package:map_presentation/src/map/models/place_details.dart';

part 'map_state.freezed.dart';

@freezed
abstract class MapState with _$MapState {
  const MapState._();
  const factory MapState({
    MapLayer? layer,
    LocationFix? location,
    @Default(MapCanvasStatus.waitingForMap) MapCanvasStatus canvasStatus,
    PlaceDetails? selected,
    @Default(true) bool loadingLayer,
    @Default(LocationTrackingStatus.idle) LocationTrackingStatus locationStatus,
    Failure? layerFailure,
    Failure? locationFailure,
    String? settingsMessage,
  }) = _MapState;

  bool get locating => locationStatus == LocationTrackingStatus.acquiring;

  String? get layerError => switch (layerFailure?.kind) {
    null => null,
    FailureKind.unauthorized || FailureKind.forbidden =>
      'Akses data wisata ditolak. Hubungi pengelola aplikasi.',
    FailureKind.network || FailureKind.timeout =>
      'Data wisata belum dapat dimuat. Periksa koneksi internet dan coba lagi.',
    FailureKind.invalidResponse => 'Format data layer belum dapat dibaca.',
    _ => 'Data wisata belum dapat diakses. Coba lagi sebentar.',
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
                    : '${locationStatus == LocationTrackingStatus.live ? 'Lokasi realtime' : 'Lokasi terakhir'} · akurasi ±${location!.accuracyMeters.toStringAsFixed(0)} m',
              FailureKind.permissionDenied => 'Izin lokasi belum diberikan. Peta wisata tetap bisa digunakan.',
              FailureKind.permissionPermanentlyDenied =>
                'Izin lokasi perlu diaktifkan melalui pengaturan aplikasi.',
              FailureKind.serviceDisabled =>
                'Aktifkan GPS untuk menampilkan lokasi kamu.',
              FailureKind.timeout =>
                'Lokasi belum ditemukan. Coba lagi di area terbuka.',
              _ => 'Lokasi perangkat belum dapat diakses. Coba lagi.',
            };
  bool get mapReady => canvasStatus == MapCanvasStatus.ready;
  String? get mapError => switch (canvasStatus) {
    MapCanvasStatus.creationTimeout =>
      'Peta belum dapat dimulai. Coba muat ulang peta.',
    MapCanvasStatus.styleTimeout =>
      'Basemap belum dapat dimuat. Periksa koneksi internet lalu coba lagi.',
    MapCanvasStatus.renderingFailure =>
      'Peta belum dapat diperbarui. Coba muat ulang basemap.',
    _ => null,
  };
}

enum LocationAction { locate, appSettings, deviceSettings }

enum LocationTrackingStatus { idle, acquiring, live, paused, failed }
