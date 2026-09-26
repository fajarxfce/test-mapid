import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_location_data/src/datasources/compass_data_source.dart';
import 'package:core_location_data/src/datasources/location_access_data_source.dart';
import 'package:core_location_data/src/datasources/location_data_source.dart';
import 'package:core_location_data/src/dto/location_fix_dto.dart';
import 'package:core_location_data/src/exceptions/location_permission_exception.dart';
import 'package:core_location_data/src/repositories/device_location_repository.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

class _Locations extends Mock implements LocationDataSource {}

class _Compass extends Mock implements CompassDataSource {}

class _Access extends Mock implements LocationAccessDataSource {}

const fix = LocationFixDto(
  latitude: -7.8,
  longitude: 110.36,
  accuracy: 12,
  heading: 90,
  headingAccuracy: 10,
  speed: 2,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Locations local;
  late _Compass compass;
  late DeviceLocationRepository repository;
  setUp(() {
    local = _Locations();
    compass = _Compass();
    final access = _Access();
    when(access.isServiceEnabled).thenAnswer((_) async => true);
    when(access.checkPermission)
        .thenAnswer((_) async => LocationPermission.whileInUse);
    repository = DeviceLocationRepository(local, access, compass);
    when(compass.watch).thenAnswer((_) => Stream.value(null));
  });

  for (final entry in <Exception, FailureKind>{
    TimeoutException('private'): FailureKind.timeout,
    const LocationPermissionException(LocationPermission.denied):
        FailureKind.permissionDenied,
    const LocationPermissionException(LocationPermission.deniedForever):
        FailureKind.permissionPermanentlyDenied,
    const LocationServiceDisabledException(): FailureKind.serviceDisabled,
    PermissionDeniedException('private'): FailureKind.permissionDenied,
    PlatformException(code: 'private'): FailureKind.unexpected,
  }.entries) {
    test(
      'one-shot and stream errors map ${entry.key.runtimeType} to ${entry.value}',
      () async {
        when(local.locate).thenThrow(entry.key);
        when(() => local.watch()).thenThrow(entry.key);
        final once = await repository.locate(requestPermission: true);
        final streamed = await repository.watch(requestPermission: true).first;
        for (final result in [once, streamed]) {
          expect(result, isA<FailureResult<LocationFix>>());
          final failure = (result as FailureResult<LocationFix>).failure;
          expect(failure.kind, entry.value);
          expect(failure.message, isNot(contains('private')));
        }
      },
    );
  }

  test(
    'compass failure falls back to GPS course and keeps tracking live',
    () async {
      final gps = StreamController<LocationFixDto>();
      final headings = StreamController<double?>()..add(null);
      when(() => local.watch()).thenAnswer((_) => gps.stream);
      when(compass.watch).thenAnswer((_) => headings.stream);
      final results = <Result<LocationFix>>[];
      final subscription = repository
          .watch(requestPermission: true)
          .listen(results.add);
      addTearDown(subscription.cancel);
      gps.add(fix);
      headings.add(20);
      await Future<void>.delayed(Duration.zero);
      expect(
        (results.last as Success<LocationFix>).value.bearing?.source,
        LocationBearingSource.compass,
      );
      headings.addError(PlatformException(code: 'NO_SENSOR'));
      await Future<void>.delayed(Duration.zero);
      expect((results.last as Success<LocationFix>).value.bearing?.degrees, 90);
      expect(
        (results.last as Success<LocationFix>).value.bearing?.source,
        LocationBearingSource.movement,
      );
      expect(gps.hasListener, isTrue);
      gps.add(
        const LocationFixDto(latitude: -7.81, longitude: 110.36, accuracy: 12),
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        (results.last as Success<LocationFix>).value.point.latitude,
        -7.81,
      );
      await subscription.cancel();
      expect(gps.hasListener, isFalse);
      expect(headings.hasListener, isFalse);
      await gps.close();
      await headings.close();
    },
  );
}
