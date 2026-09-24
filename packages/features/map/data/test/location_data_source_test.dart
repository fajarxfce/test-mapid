import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_data/src/datasources/local/geolocator_location_data_source.dart';
import 'package:map_data/src/dto/user_location_dto.dart';
import 'package:map_data/src/repositories/device_user_location_repository.dart';
import 'package:map_domain/map_domain.dart';
import 'package:mocktail/mocktail.dart';

class _Geolocator extends Mock implements GeolocatorPlatform {}

void main() {
  late _Geolocator platform;
  late GeolocatorLocationDataSource source;
  setUpAll(() => registerFallbackValue(const LocationSettings()));
  setUp(() {
    platform = _Geolocator();
    source = GeolocatorLocationDataSource(platform);
    when(platform.isLocationServiceEnabled).thenAnswer((_) async => true);
    when(platform.checkPermission)
        .thenAnswer((_) async => LocationPermission.whileInUse);
    when(
      () => platform.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenAnswer(
      (_) async => Position(
        longitude: 110.36,
        latitude: -7.8,
        timestamp: DateTime(2026),
        accuracy: 12,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      ),
    );
  });
  test('maps a real platform fix into the domain with accuracy', () async {
    final repository = DeviceUserLocationRepository(source);
    final result = await repository.locate() as Success<UserLocation>;
    expect(result.value.point.latitude, -7.8);
    expect(result.value.point.longitude, 110.36);
    expect(result.value.accuracyMeters, 12);
    verifyNever(platform.requestPermission);
  });
  test('asks for permission once and continues when granted', () async {
    when(platform.checkPermission)
        .thenAnswer((_) async => LocationPermission.denied);
    when(platform.requestPermission)
        .thenAnswer((_) async => LocationPermission.whileInUse);
    expect(await source.locate(), isA<Success<UserLocationDto>>());
    verify(platform.requestPermission).called(1);
  });
  test('denial does not query the GPS position', () async {
    when(platform.checkPermission)
        .thenAnswer((_) async => LocationPermission.denied);
    when(platform.requestPermission)
        .thenAnswer((_) async => LocationPermission.denied);
    final result = await source.locate() as FailureResult<UserLocationDto>;
    expect(result.failure.kind, FailureKind.permissionDenied);
    verifyNever(
      () => platform.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    );
  });
  test('permanent denial offers an application-settings recovery', () async {
    when(platform.checkPermission)
        .thenAnswer((_) async => LocationPermission.deniedForever);
    final result = await source.locate() as FailureResult<UserLocationDto>;
    expect(result.failure.kind, FailureKind.permissionPermanentlyDenied);
    verifyNever(platform.requestPermission);
    when(platform.openAppSettings).thenAnswer((_) async => true);
    expect(
      await DeviceUserLocationRepository(source)
          .openSettings(LocationSettingsTarget.application),
      isTrue,
    );
    verify(platform.openAppSettings).called(1);
  });
  test('disabled GPS is distinct from denied permission', () async {
    when(platform.isLocationServiceEnabled).thenAnswer((_) async => false);
    final result = await source.locate() as FailureResult<UserLocationDto>;
    expect(result.failure.kind, FailureKind.serviceDisabled);
    verifyNever(platform.checkPermission);
    when(platform.openLocationSettings).thenAnswer((_) async => true);
    expect(
      await DeviceUserLocationRepository(source)
          .openSettings(LocationSettingsTarget.device),
      isTrue,
    );
  });
  test('a GPS timeout is recoverable', () async {
    when(
      () => platform.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenThrow(TimeoutException('private'));
    final result = await source.locate() as FailureResult<UserLocationDto>;
    expect(result.failure.kind, FailureKind.timeout);
    expect(result.failure.message, isNot(contains('private')));
  });
}
