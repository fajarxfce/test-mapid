import 'dart:async';

import 'package:core_location_data/src/datasources/geolocator_location_data_source.dart';
import 'package:core_location_data/src/dto/location_fix_dto.dart';
import 'package:core_location_data/src/mappers/map_location_fix.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

class _Platform extends Mock implements GeolocatorPlatform {}

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
      final fixes = <LocationFixDto>[];
      final subscription = source.watch().listen(fixes.add);
      await settle();
      positions.add(position());
      positions.add(position(latitude: -7.81));
      await settle();
      expect(fixes.map((fix) => fix.latitude), [-7.8, -7.81]);
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

  test('raw platform stream errors reach the caller unchanged', () async {
    const error = LocationServiceDisabledException();
    final result = expectLater(
      source.watch(),
      emitsInOrder([isA<LocationFixDto>(), emitsError(same(error))]),
    );
    await settle();
    positions.add(position());
    positions.addError(error);
    await result;
    await settle();
    expect(positions.hasListener, isFalse);
  });

  test(
    'only the first fix has a timeout; stationary tracking stays active',
    () {
      fakeAsync((clock) {
        final results = <LocationFixDto>[];
        final subscription = source.watch().listen(results.add);
        clock.flushMicrotasks();
        positions.add(position());
        clock.flushMicrotasks();
        clock.elapse(const Duration(minutes: 2));
        expect(results.single, isA<LocationFixDto>());
        expect(positions.hasListener, isTrue);
        unawaited(subscription.cancel());
        clock.flushMicrotasks();
        expect(positions.hasListener, isFalse);
      });
    },
  );

  test('first-fix timeout cancels the native stream', () {
    fakeAsync((clock) {
      final errors = <Object>[];
      final subscription = source.watch().listen(
        (_) => fail('Unexpected fix'),
        onError: errors.add,
      );
      clock.flushMicrotasks();
      clock.elapse(const Duration(seconds: 21));
      expect(errors.single, isA<TimeoutException>());
      expect(positions.hasListener, isFalse);
      unawaited(subscription.cancel());
      clock.flushMicrotasks();
    });
  });

  test(
    'bearing distinguishes compass, moving GPS course, and stationary GPS',
    () {
      final moving = LocationFixDto.fromPosition(position());
      expect(
        mapLocationFix(moving).bearing?.source,
        LocationBearingSource.movement,
      );
      expect(mapLocationFix(moving).bearing?.degrees, 90);
      expect(
        mapLocationFix(moving, compassHeading: 15).bearing?.source,
        LocationBearingSource.compass,
      );
      expect(mapLocationFix(moving, compassHeading: 15).bearing?.degrees, 15);
      expect(
        mapLocationFix(LocationFixDto.fromPosition(position(speed: 0))).bearing,
        isNull,
      );
      expect(
        mapLocationFix(LocationFixDto.fromPosition(position(heading: -1)))
            .bearing,
        isNull,
      );
      expect(mapLocationFix(moving).timestamp, DateTime.utc(2026));
    },
  );
}
