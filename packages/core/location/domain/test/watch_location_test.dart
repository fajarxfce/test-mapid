import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_lifecycle_domain/core_lifecycle_domain.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

class FakeLifecycleRepository implements AppLifecycleRepository {
  final foreground = BehaviorSubject<bool>.seeded(true);
  @override
  Stream<bool> watchForeground() => foreground.stream;
}

class FakeLocationRepository implements LocationRepository {
  final requests = <bool>[];
  final sessions = <StreamController<Result<LocationFix>>>[];
  @override
  Stream<Result<LocationFix>> watch({required bool requestPermission}) {
    requests.add(requestPermission);
    final session = StreamController<Result<LocationFix>>();
    sessions.add(session);
    return session.stream;
  }

  @override
  Future<Result<LocationFix>> locate({required bool requestPermission}) async {
    requests.add(requestPermission);
    return const Success(fix);
  }

  @override
  Future<Result<void>> openSettings(LocationSettingsTarget target) async =>
      const Success(null);
}

const fix = LocationFix(
  point: GeoPoint(latitude: -7.8, longitude: 110.36),
  accuracyMeters: 12,
);

void main() {
  late FakeLifecycleRepository lifecycle;
  late FakeLocationRepository locations;
  late WatchLocation watch;
  Future<void> settle() => Future<void>.delayed(Duration.zero);
  setUp(() {
    lifecycle = FakeLifecycleRepository();
    locations = FakeLocationRepository();
    watch = WatchLocation(locations, lifecycle);
  });
  tearDown(() async {
    await lifecycle.foreground.close();
    for (final session in locations.sessions) {
      await session.close();
    }
  });

  test(
    'a direct location request explicitly allows a permission prompt',
    () async {
      expect(
        await GetCurrentLocation(locations)(),
        isA<Success<LocationFix>>(),
      );
      expect(locations.requests, [true]);
    },
  );

  test('background pauses acquisition and all resumes are passive', () async {
    final values = <Result<LocationFix>>[];
    final subscription = watch().listen(values.add);
    addTearDown(subscription.cancel);
    await settle();
    expect(locations.requests, [true]);
    locations.sessions.single.add(const Success(fix));
    await settle();
    expect(values.last, isA<Success<LocationFix>>());
    lifecycle.foreground.add(false);
    await settle();
    expect(locations.sessions.single.hasListener, isFalse);
    expect((values.last as FailureResult).failure.kind, FailureKind.cancelled);
    lifecycle.foreground.add(true);
    await settle();
    lifecycle.foreground.add(true);
    await settle();
    expect(locations.requests, [true, false]);
    locations.sessions.last.add(const Success(fix));
    await settle();
    expect(values.last, isA<Success<LocationFix>>());
    await subscription.cancel();
    expect(lifecycle.foreground.hasListener, isFalse);
    expect(locations.sessions.last.hasListener, isFalse);
    lifecycle.foreground.add(false);
    lifecycle.foreground.add(true);
    await settle();
    expect(locations.sessions, hasLength(2));
  });

  for (final failure in [
    FailureKind.permissionPermanentlyDenied,
    FailureKind.serviceDisabled,
    FailureKind.timeout,
  ]) {
    test('a failed $failure session can recover after Settings', () async {
      final values = <Result<LocationFix>>[];
      var done = false;
      final subscription = watch().listen(
        values.add,
        onDone: () => done = true,
      );
      addTearDown(subscription.cancel);
      await settle();
      locations.sessions.single.add(
        FailureResult(Failure(failure, 'Unavailable')),
      );
      await locations.sessions.single.close();
      await settle();
      expect(done, isFalse);
      expect(values.last, isA<FailureResult<LocationFix>>());
      lifecycle.foreground.add(false);
      await settle();
      lifecycle.foreground.add(true);
      await settle();
      locations.sessions.last.add(const Success(fix));
      await settle();
      expect(locations.requests, [true, false]);
      expect(values.last, isA<Success<LocationFix>>());
    });
  }

  test(
    'starting hidden defers acquisition and preserves the first prompt',
    () async {
      lifecycle.foreground.add(false);
      final subscription = watch().listen((_) {});
      addTearDown(subscription.cancel);
      await settle();
      expect(locations.requests, isEmpty);
      lifecycle.foreground.add(true);
      await settle();
      expect(locations.requests, [true]);
    },
  );

  test('a fresh explicit request gets its own prompt allowance', () async {
    final first = watch().listen((_) {});
    await settle();
    await first.cancel();
    final retry = watch().listen((_) {});
    addTearDown(retry.cancel);
    await settle();
    expect(locations.requests, [true, true]);
  });
}
