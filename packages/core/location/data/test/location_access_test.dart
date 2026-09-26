import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_lifecycle_domain/core_lifecycle_domain.dart';
import 'package:core_location_data/src/datasources/compass_data_source.dart';
import 'package:core_location_data/src/datasources/geolocator_location_access_data_source.dart';
import 'package:core_location_data/src/datasources/geolocator_location_data_source.dart';
import 'package:core_location_data/src/repositories/device_location_repository.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

class _Platform extends Mock implements GeolocatorPlatform {}

class _Compass extends Mock implements CompassDataSource {}

class _Lifecycle extends Mock implements AppLifecycleRepository {}

void main() {
  late _Platform platform;
  late _Compass compass;
  late GeolocatorLocationAccessDataSource access;
  late DeviceLocationRepository repository;
  final position = Position(
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
  );
  setUpAll(() => registerFallbackValue(const LocationSettings()));
  setUp(() {
    platform = _Platform();
    compass = _Compass();
    access = GeolocatorLocationAccessDataSource(platform);
    repository = DeviceLocationRepository(
      GeolocatorLocationDataSource(platform),
      access,
      compass,
    );
    when(platform.isLocationServiceEnabled).thenAnswer((_) async => true);
    when(platform.checkPermission)
        .thenAnswer((_) async => LocationPermission.whileInUse);
    when(compass.watch).thenAnswer((_) => Stream.value(null));
    when(
      () => platform.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenAnswer((_) async => position);
    when(
      () => platform.getPositionStream(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenAnswer((_) => Stream.value(position));
  });
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test(
    'checking access does not request permission or open Settings',
    () async {
      when(platform.checkPermission)
          .thenAnswer((_) async => LocationPermission.deniedForever);
      expect(await access.checkPermission(), LocationPermission.deniedForever);
      verifyNever(platform.requestPermission);
      verifyNever(platform.openAppSettings);
    },
  );

  test(
    'repository checks service, permission, requests access, then reads GPS',
    () async {
      when(platform.checkPermission)
          .thenAnswer((_) async => LocationPermission.denied);
      when(platform.requestPermission)
          .thenAnswer((_) async => LocationPermission.whileInUse);
      expect(
        await repository.locate(requestPermission: true),
        isA<Success<LocationFix>>(),
      );
      verifyInOrder([
        platform.isLocationServiceEnabled,
        platform.checkPermission,
        platform.requestPermission,
        () => platform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ]);
    },
  );

  for (final entry in {
    LocationPermission.denied: FailureKind.permissionDenied,
    LocationPermission.deniedForever: FailureKind.permissionPermanentlyDenied,
  }.entries) {
    test(
      'passive access maps ${entry.key} without prompting or starting sensors',
      () async {
        when(platform.checkPermission).thenAnswer((_) async => entry.key);
        final result =
            await repository.watch(requestPermission: false).first
                as FailureResult<LocationFix>;
        expect(result.failure.kind, entry.value);
        verifyNever(platform.requestPermission);
        verifyNever(
          () => platform.getPositionStream(
            locationSettings: any(named: 'locationSettings'),
          ),
        );
        verifyNever(compass.watch);
        verifyNever(platform.openAppSettings);
      },
    );
  }

  test('denied request never starts GPS', () async {
    when(platform.checkPermission)
        .thenAnswer((_) async => LocationPermission.denied);
    when(platform.requestPermission)
        .thenAnswer((_) async => LocationPermission.denied);
    final result = await repository.locate(
      requestPermission: true,
    ) as FailureResult<LocationFix>;
    expect(result.failure.kind, FailureKind.permissionDenied);
    verifyNever(
      () => platform.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    );
  });

  test('disabled service stops before permission and sensor access', () async {
    when(platform.isLocationServiceEnabled).thenAnswer((_) async => false);
    final result =
        await repository.watch(requestPermission: true).first
            as FailureResult<LocationFix>;
    expect(result.failure.kind, FailureKind.serviceDisabled);
    verifyNever(platform.checkPermission);
    verifyNever(compass.watch);
  });

  for (final pendingStep in ['service', 'permission', 'prompt']) {
    test(
      'cancellation during $pendingStep prevents subsequent native operations',
      () async {
        final service = Completer<bool>();
        final permission = Completer<LocationPermission>();
        final prompt = Completer<LocationPermission>();
        final started = Completer<void>();
        if (pendingStep == 'service') {
          when(platform.isLocationServiceEnabled).thenAnswer((_) {
            started.complete();
            return service.future;
          });
        } else if (pendingStep == 'permission') {
          when(platform.checkPermission).thenAnswer((_) {
            started.complete();
            return permission.future;
          });
        } else {
          when(platform.checkPermission)
              .thenAnswer((_) async => LocationPermission.denied);
          when(platform.requestPermission).thenAnswer((_) {
            started.complete();
            return prompt.future;
          });
        }
        final subscription = repository
            .watch(requestPermission: true)
            .listen((_) => fail('Late result'));
        await started.future;
        await subscription.cancel().timeout(const Duration(seconds: 1));
        service.complete(true);
        permission.complete(LocationPermission.denied);
        prompt.complete(LocationPermission.whileInUse);
        await settle();
        if (pendingStep != 'prompt') verifyNever(platform.requestPermission);
        if (pendingStep == 'service') verifyNever(platform.checkPermission);
        verifyNever(
          () => platform.getPositionStream(
            locationSettings: any(named: 'locationSettings'),
          ),
        );
        verifyNever(compass.watch);
      },
    );
  }

  test('Settings commands use the access adapter and preserve technical errors there', () async {
    when(platform.openAppSettings).thenAnswer((_) async => true);
    expect(
      await repository.openSettings(LocationSettingsTarget.application),
      isA<Success<void>>(),
    );
    verify(platform.openAppSettings).called(1);
    when(platform.openLocationSettings).thenAnswer((_) async => false);
    expect(
      await repository.openSettings(LocationSettingsTarget.device),
      isA<FailureResult<void>>(),
    );
    final error = PlatformException(code: 'private');
    when(platform.openLocationSettings).thenThrow(error);
    await expectLater(access.openLocationSettings, throwsA(same(error)));
    final result = await repository.openSettings(
      LocationSettingsTarget.device,
    ) as FailureResult<void>;
    expect(result.failure.kind, FailureKind.unexpected);
    expect(result.failure.message, isNot(contains('private')));
  });

  for (final failure in [
    FailureKind.permissionPermanentlyDenied,
    FailureKind.serviceDisabled,
  ]) {
    test(
      'WatchLocation recovers $failure through repository and OS adapters',
      () async {
        final lifecycle = _Lifecycle();
        final foreground = BehaviorSubject<bool>.seeded(true);
        when(lifecycle.watchForeground).thenAnswer((_) => foreground.stream);
        when(platform.isLocationServiceEnabled)
            .thenAnswer((_) async => failure != FailureKind.serviceDisabled);
        when(platform.checkPermission)
            .thenAnswer((_) async => LocationPermission.deniedForever);
        final gps = StreamController<Position>();
        final headings = StreamController<double?>()..add(null);
        when(
          () => platform.getPositionStream(
            locationSettings: any(named: 'locationSettings'),
          ),
        ).thenAnswer((_) => gps.stream);
        when(compass.watch).thenAnswer((_) => headings.stream);
        final values = <Result<LocationFix>>[];
        final subscription = WatchLocation(
          repository,
          lifecycle,
        )().listen(values.add);
        await settle();
        expect((values.last as FailureResult).failure.kind, failure);
        verifyNever(compass.watch);
        foreground.add(false);
        await settle();
        when(platform.isLocationServiceEnabled).thenAnswer((_) async => true);
        when(platform.checkPermission)
            .thenAnswer((_) async => LocationPermission.whileInUse);
        foreground.add(true);
        await settle();
        gps.add(position);
        await settle();
        expect(values.last, isA<Success<LocationFix>>());
        verifyNever(platform.requestPermission);
        foreground.add(false);
        await settle();
        expect(gps.hasListener, isFalse);
        expect(headings.hasListener, isFalse);
        await subscription.cancel();
        expect(foreground.hasListener, isFalse);
        await gps.close();
        await headings.close();
        await foreground.close();
      },
    );
  }

  test(
    'GPS failure releases both sensors but leaves resume recovery active',
    () async {
      final lifecycle = _Lifecycle();
      final foreground = BehaviorSubject<bool>.seeded(true);
      when(lifecycle.watchForeground).thenAnswer((_) => foreground.stream);
      final gps = StreamController<Position>();
      final headings = StreamController<double?>()..add(null);
      when(
        () => platform.getPositionStream(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) => gps.stream);
      when(compass.watch).thenAnswer((_) => headings.stream);
      final values = <Result<LocationFix>>[];
      final subscription = WatchLocation(
        repository,
        lifecycle,
      )().listen(values.add);
      await settle();
      gps.addError(const LocationServiceDisabledException());
      await settle();
      expect(
        (values.last as FailureResult).failure.kind,
        FailureKind.serviceDisabled,
      );
      expect(gps.hasListener, isFalse);
      expect(headings.hasListener, isFalse);
      expect(foreground.hasListener, isTrue);
      await subscription.cancel();
      await gps.close();
      await headings.close();
      await foreground.close();
    },
  );
}
