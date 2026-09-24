import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_location_data/src/datasources/compass_data_source.dart';
import 'package:core_location_data/src/datasources/geolocator_location_data_source.dart';
import 'package:core_location_data/src/datasources/location_data_source.dart';
import 'package:core_location_data/src/dto/location_fix_dto.dart';
import 'package:core_location_data/src/repositories/device_location_repository.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

class _Platform extends Mock implements GeolocatorPlatform {}

class _Locations extends Mock implements LocationDataSource {}

class _Compass extends Mock implements CompassDataSource {}

Position position({
  double latitude = -7.8,
  double heading = 90,
  double speed = 2,
}) => Position(
  longitude: 110.36,
  latitude: latitude,
  timestamp: DateTime.utc(2026),
  accuracy: 12,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: heading,
  headingAccuracy: 15,
  speed: speed,
  speedAccuracy: 0,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Platform platform;
  late GeolocatorLocationDataSource source;
  late StreamController<Position> positions;
  setUpAll(() => registerFallbackValue(const LocationSettings()));
  setUp(() {
    platform = _Platform();
    source = GeolocatorLocationDataSource(platform);
    positions = StreamController<Position>();
    when(platform.isLocationServiceEnabled).thenAnswer((_) async => true);
    when(platform.checkPermission)
        .thenAnswer((_) async => LocationPermission.whileInUse);
    when(
      () => platform.getPositionStream(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenAnswer((_) => positions.stream);
  });
  tearDown(() {
    unawaited(positions.close());
  });
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test(
    'one GPS stream emits successive fixes and cancellation releases it',
    () async {
      final fixes = <Result<LocationFixDto>>[];
      final subscription = source.watch().listen(fixes.add);
      await settle();
      positions.add(position());
      positions.add(position(latitude: -7.81));
      await settle();
      expect(
        fixes.whereType<Success<LocationFixDto>>().map(
          (fix) => fix.value.latitude,
        ),
        [-7.8, -7.81],
      );
      final settings =
          verify(
                () => platform.getPositionStream(
                  locationSettings: captureAny(named: 'locationSettings'),
                ),
              ).captured.single
              as AndroidSettings;
      expect(settings.intervalDuration, const Duration(seconds: 1));
      expect(settings.distanceFilter, 0);
      expect(settings.timeLimit, isNull);
      await subscription.cancel();
      expect(positions.hasListener, isFalse);
      verifyNever(
        () => platform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      );
    },
  );

  test('denied permission never starts the GPS stream', () async {
    when(platform.checkPermission)
        .thenAnswer((_) async => LocationPermission.deniedForever);
    final results = await source.watch().toList();
    expect(
      (results.single as FailureResult).failure.kind,
      FailureKind.permissionPermanentlyDenied,
    );
    verifyNever(
      () => platform.getPositionStream(
        locationSettings: any(named: 'locationSettings'),
      ),
    );
  });

  test('a passive permission check never opens a permission dialog', () async {
    when(platform.checkPermission)
        .thenAnswer((_) async => LocationPermission.denied);
    final results = await source.watch(requestPermission: false).toList();
    expect(
      (results.single as FailureResult).failure.kind,
      FailureKind.permissionDenied,
    );
    verifyNever(platform.requestPermission);
    verifyNever(
      () => platform.getPositionStream(
        locationSettings: any(named: 'locationSettings'),
      ),
    );
  });

  for (final failure in [
    FailureKind.permissionPermanentlyDenied,
    FailureKind.serviceDisabled,
  ]) {
    test(
      'returning from Settings recovers $failure without a new request',
      () async {
        WidgetsBinding.instance.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        when(platform.isLocationServiceEnabled)
            .thenAnswer((_) async => failure != FailureKind.serviceDisabled);
        when(platform.checkPermission)
            .thenAnswer((_) async => LocationPermission.deniedForever);
        final compass = _Compass();
        final headings = <StreamController<double?>>[];
        when(compass.watch).thenAnswer((_) {
          final stream = StreamController<double?>()..add(null);
          headings.add(stream);
          return stream.stream;
        });
        final results = <Result<LocationFix>>[];
        final recovered = Completer<void>();
        final subscription = DeviceLocationRepository(source, compass)
            .watch()
            .listen((result) {
              results.add(result);
              if (result is Success<LocationFix> && !recovered.isCompleted) {
                recovered.complete();
              }
            });
        addTearDown(subscription.cancel);
        await settle();
        expect((results.last as FailureResult).failure.kind, failure);
        expect(headings.single.hasListener, isFalse);
        for (final state in [
          AppLifecycleState.inactive,
          AppLifecycleState.hidden,
          AppLifecycleState.paused,
        ]) {
          WidgetsBinding.instance.handleAppLifecycleStateChanged(state);
        }
        await settle();
        when(platform.isLocationServiceEnabled).thenAnswer((_) async => true);
        when(platform.checkPermission)
            .thenAnswer((_) async => LocationPermission.whileInUse);
        for (final state in [
          AppLifecycleState.hidden,
          AppLifecycleState.inactive,
          AppLifecycleState.resumed,
        ]) {
          WidgetsBinding.instance.handleAppLifecycleStateChanged(state);
        }
        await settle();
        positions.add(position());
        await recovered.future.timeout(const Duration(seconds: 2));
        expect(results.last, isA<Success<LocationFix>>());
        verifyNever(platform.requestPermission);
        await subscription.cancel();
        expect(positions.hasListener, isFalse);
        expect(headings.last.hasListener, isFalse);
        // A disposed watcher must not restart sensors on a later resume.
        for (final state in [
          AppLifecycleState.inactive,
          AppLifecycleState.hidden,
          AppLifecycleState.paused,
        ]) {
          WidgetsBinding.instance.handleAppLifecycleStateChanged(state);
        }
        for (final state in [
          AppLifecycleState.hidden,
          AppLifecycleState.inactive,
          AppLifecycleState.resumed,
        ]) {
          WidgetsBinding.instance.handleAppLifecycleStateChanged(state);
        }
        await settle();
        expect(headings, hasLength(2));
        for (final stream in headings) {
          await stream.close();
        }
      },
    );
  }

  test(
    'returning without granting permission does not prompt repeatedly',
    () async {
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      when(platform.checkPermission)
          .thenAnswer((_) async => LocationPermission.denied);
      when(platform.requestPermission)
          .thenAnswer((_) async => LocationPermission.denied);
      final compass = _Compass();
      when(compass.watch).thenAnswer((_) => Stream.value(null));
      final results = <Result<LocationFix>>[];
      final subscription = DeviceLocationRepository(
        source,
        compass,
      ).watch().listen(results.add);
      await settle();
      for (var i = 0; i < 2; i++) {
        for (final state in [
          AppLifecycleState.inactive,
          AppLifecycleState.hidden,
          AppLifecycleState.paused,
        ]) {
          WidgetsBinding.instance.handleAppLifecycleStateChanged(state);
        }
        await settle();
        for (final state in [
          AppLifecycleState.hidden,
          AppLifecycleState.inactive,
          AppLifecycleState.resumed,
        ]) {
          WidgetsBinding.instance.handleAppLifecycleStateChanged(state);
        }
        await settle();
        expect(
          (results.last as FailureResult).failure.kind,
          FailureKind.permissionDenied,
        );
      }
      verify(platform.requestPermission).called(1);
      await subscription.cancel();
    },
  );

  test(
    'a platform stream failure emits a typed failure and closes tracking',
    () async {
      final result = source.watch().toList();
      await settle();
      positions.add(position());
      positions.addError(const LocationServiceDisabledException());
      final values = await result;
      expect(values, hasLength(2));
      expect(
        (values.last as FailureResult).failure.kind,
        FailureKind.serviceDisabled,
      );
      await settle();
      expect(positions.hasListener, isFalse);
    },
  );

  test(
    'cancelling during a permission prompt cannot start GPS later',
    () async {
      final permission = Completer<LocationPermission>();
      when(platform.checkPermission)
          .thenAnswer((_) async => LocationPermission.denied);
      when(platform.requestPermission).thenAnswer((_) => permission.future);
      final subscription = source.watch().listen((_) => fail('Unexpected fix'));
      await settle();
      await subscription.cancel().timeout(const Duration(seconds: 1));
      permission.complete(LocationPermission.whileInUse);
      await settle();
      verifyNever(
        () => platform.getPositionStream(
          locationSettings: any(named: 'locationSettings'),
        ),
      );
    },
  );

  test(
    'only the first fix has a timeout; stationary tracking stays active',
    () {
      fakeAsync((clock) {
        final results = <Result<LocationFixDto>>[];
        final subscription = source.watch().listen(results.add);
        clock.flushMicrotasks();
        positions.add(position());
        clock.flushMicrotasks();
        clock.elapse(const Duration(minutes: 2));
        expect(results.single, isA<Success<LocationFixDto>>());
        expect(positions.hasListener, isTrue);
        unawaited(subscription.cancel());
        clock.flushMicrotasks();
        expect(positions.hasListener, isFalse);
      });
    },
  );

  test('first-fix timeout cancels the native stream', () {
    fakeAsync((clock) {
      final results = <Result<LocationFixDto>>[];
      final subscription = source.watch().listen(results.add);
      clock.flushMicrotasks();
      clock.elapse(const Duration(seconds: 21));
      expect(
        (results.single as FailureResult).failure.kind,
        FailureKind.timeout,
      );
      expect(positions.hasListener, isFalse);
      unawaited(subscription.cancel());
      clock.flushMicrotasks();
    });
  });

  test(
    'bearing distinguishes compass, moving GPS course, and stationary GPS',
    () {
      final moving = LocationFixDto.fromPosition(position());
      expect(moving.toEntity().bearing?.source, LocationBearingSource.movement);
      expect(moving.toEntity().bearing?.degrees, 90);
      expect(
        moving.toEntity(compassHeading: 15).bearing?.source,
        LocationBearingSource.compass,
      );
      expect(moving.toEntity(compassHeading: 15).bearing?.degrees, 15);
      expect(
        LocationFixDto.fromPosition(position(speed: 0)).toEntity().bearing,
        isNull,
      );
      expect(
        LocationFixDto.fromPosition(position(heading: -1)).toEntity().bearing,
        isNull,
      );
      expect(moving.toEntity().timestamp, DateTime.utc(2026));
    },
  );

  test(
    'background releases GPS and compass; resume creates fresh streams',
    () async {
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      final local = _Locations();
      final compass = _Compass();
      final gpsStreams = <StreamController<Result<LocationFixDto>>>[];
      final compassStreams = <StreamController<double?>>[];
      when(
        () => local.watch(requestPermission: any(named: 'requestPermission')),
      ).thenAnswer((_) {
        final stream = StreamController<Result<LocationFixDto>>();
        gpsStreams.add(stream);
        return stream.stream;
      });
      when(compass.watch).thenAnswer((_) {
        final stream = StreamController<double?>();
        compassStreams.add(stream);
        stream.add(null);
        return stream.stream;
      });
      final results = <Result<LocationFix>>[];
      final subscription = DeviceLocationRepository(
        local,
        compass,
      ).watch().listen(results.add);
      await settle();
      gpsStreams.single.add(Success(LocationFixDto.fromPosition(position())));
      await settle();
      compassStreams.single.add(180);
      await settle();
      expect(
        (results.last as Success<LocationFix>).value.bearing?.degrees,
        180,
      );
      expect(gpsStreams, hasLength(1));
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.inactive,
      );
      await settle();
      expect(
        gpsStreams.single.hasListener,
        isTrue,
        reason: 'Permission dialogs must not interrupt tracking',
      );
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.hidden,
      );
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.paused,
      );
      await settle();
      expect(gpsStreams.single.hasListener, isFalse);
      expect(compassStreams.single.hasListener, isFalse);
      expect(
        (results.last as FailureResult).failure.kind,
        FailureKind.cancelled,
      );
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.hidden,
      );
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.inactive,
      );
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await settle();
      expect(gpsStreams, hasLength(2));
      gpsStreams.last.add(
        Success(LocationFixDto.fromPosition(position(latitude: -7.81))),
      );
      await settle();
      expect(
        (results.last as Success<LocationFix>).value.point.latitude,
        -7.81,
      );
      await subscription.cancel();
      expect(gpsStreams.last.hasListener, isFalse);
      expect(compassStreams.last.hasListener, isFalse);
      for (final stream in [...gpsStreams, ...compassStreams]) {
        await stream.close();
      }
    },
  );

  test(
    'GPS failure releases sensors but keeps observing permission recovery',
    () async {
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      final local = _Locations();
      final compass = _Compass();
      final gps = StreamController<Result<LocationFixDto>>();
      final headings = StreamController<double?>()..add(null);
      when(
        () => local.watch(requestPermission: any(named: 'requestPermission')),
      ).thenAnswer((_) => gps.stream);
      when(compass.watch).thenAnswer((_) => headings.stream);
      final results = <Result<LocationFix>>[];
      var done = false;
      final subscription = DeviceLocationRepository(
        local,
        compass,
      ).watch().listen(results.add, onDone: () => done = true);
      await settle();
      gps.add(
        const FailureResult(
          Failure(FailureKind.serviceDisabled, 'GPS disabled'),
        ),
      );
      await settle();
      expect(done, isFalse);
      expect(headings.hasListener, isFalse);
      expect(gps.hasListener, isFalse);
      expect(
        (results.last as FailureResult).failure.kind,
        FailureKind.serviceDisabled,
      );
      await subscription.cancel();
      await gps.close();
      await headings.close();
    },
  );
}
