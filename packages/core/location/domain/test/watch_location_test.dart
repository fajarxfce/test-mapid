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
  int reads = 0;
  final sessions = <StreamController<Result<LocationFix>>>[];
  @override
  Stream<Result<LocationFix>> watch() {
    reads++;
    final session = StreamController<Result<LocationFix>>();
    sessions.add(session);
    return session.stream;
  }

  @override
  Future<Result<LocationFix>> locate() async {
    reads++;
    return const Success(fix);
  }
}

class FakeAccessRepository implements LocationAccessRepository {
  Result<void> status = const Success(null);
  Result<void> permission = const Success(null);
  int checks = 0;
  int requests = 0;
  @override
  Stream<Result<void>> checkAccess() {
    checks++;
    return Stream.value(status);
  }

  @override
  Future<Result<void>> requestPermission() async {
    requests++;
    return permission;
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
  late FakeAccessRepository access;
  late WatchLocation watch;
  Future<void> settle() => Future<void>.delayed(Duration.zero);
  setUp(() {
    lifecycle = FakeLifecycleRepository();
    locations = FakeLocationRepository();
    access = FakeAccessRepository();
    watch = WatchLocation(locations, access, lifecycle);
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
      access.status = const FailureResult(
        Failure(FailureKind.permissionDenied, 'Denied'),
      );
      expect(
        await GetCurrentLocation(locations, access)(),
        isA<Success<LocationFix>>(),
      );
      expect(locations.reads, 1);
      expect(access.requests, 1);
    },
  );

  for (final kind in [
    FailureKind.permissionPermanentlyDenied,
    FailureKind.serviceDisabled,
    FailureKind.unexpected,
  ]) {
    test('$kind prevents prompting and GPS acquisition', () async {
      access.status = FailureResult(Failure(kind, 'Unavailable'));
      final result = await GetCurrentLocation(locations, access)();
      expect((result as FailureResult<LocationFix>).failure.kind, kind);
      final streamResult = await watch().first;
      expect((streamResult as FailureResult<LocationFix>).failure.kind, kind);
      expect(access.requests, 0);
      expect(locations.reads, 0);
    });
  }

  test(
    'denial prevents acquisition; resume stays passive until access returns',
    () async {
      const denied = FailureResult<void>(
        Failure(FailureKind.permissionDenied, 'Denied'),
      );
      access.status = denied;
      access.permission = denied;
      final values = <Result<LocationFix>>[];
      final subscription = watch().listen(values.add);
      addTearDown(subscription.cancel);
      await settle();
      expect(access.requests, 1);
      expect(locations.reads, 0);
      expect(
        (values.last as FailureResult).failure.kind,
        FailureKind.permissionDenied,
      );

      lifecycle.foreground.add(false);
      await settle();
      lifecycle.foreground.add(true);
      await settle();
      expect(access.checks, 2);
      expect(access.requests, 1);
      expect(locations.reads, 0);
      expect(
        (values.last as FailureResult).failure.kind,
        FailureKind.permissionDenied,
      );

      lifecycle.foreground.add(false);
      await settle();
      access.status = const Success(null);
      lifecycle.foreground.add(true);
      await settle();
      expect(access.checks, 3);
      expect(access.requests, 1);
      expect(locations.reads, 1);
      locations.sessions.single.add(const Success(fix));
      await settle();
      expect(values.last, isA<Success<LocationFix>>());
    },
  );

  test('background pauses acquisition and all resumes are passive', () async {
    final values = <Result<LocationFix>>[];
    final subscription = watch().listen(values.add);
    addTearDown(subscription.cancel);
    await settle();
    expect(locations.reads, 1);
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
    expect(access.checks, 2);
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
      expect(access.checks, 2);
      expect(values.last, isA<Success<LocationFix>>());
    });
  }

  test(
    'starting hidden defers acquisition and preserves the first prompt',
    () async {
      access.status = const FailureResult(
        Failure(FailureKind.permissionDenied, 'Denied'),
      );
      lifecycle.foreground.add(false);
      final subscription = watch().listen((_) {});
      addTearDown(subscription.cancel);
      await settle();
      expect(access.checks, 0);
      lifecycle.foreground.add(true);
      await settle();
      expect(locations.reads, 1);
      expect(access.requests, 1);
    },
  );

  test('a fresh explicit request gets its own prompt allowance', () async {
    access.status = const FailureResult(
      Failure(FailureKind.permissionDenied, 'Denied'),
    );
    final first = watch().listen((_) {});
    await settle();
    await first.cancel();
    final retry = watch().listen((_) {});
    addTearDown(retry.cancel);
    await settle();
    expect(access.requests, 2);
  });
}
