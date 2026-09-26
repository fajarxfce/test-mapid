import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_location_data/src/calls/safe_location_call.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  test(
    'preserves mapped results without nesting or replacing failures',
    () async {
      for (final result in <Result<int?>>[
        const Success(42),
        const Success(null),
        const FailureResult(
          Failure(FailureKind.permissionPermanentlyDenied, 'Denied'),
        ),
      ]) {
        expect(await safeLocationCall(() => result), same(result));
        expect(await safeLocationCall(() async => result), same(result));
        expect(
          await safeLocationStream(() => Stream.value(result)).first,
          same(result),
        );
      }
    },
  );

  for (final entry in <Object, FailureKind>{
    TimeoutException('private'): FailureKind.timeout,
    const LocationServiceDisabledException(): FailureKind.serviceDisabled,
    PermissionDeniedException('private'): FailureKind.permissionDenied,
    PlatformException(code: 'private'): FailureKind.unexpected,
    StateError('private'): FailureKind.unexpected,
  }.entries) {
    test('${entry.key.runtimeType} maps across all execution paths', () async {
      final results = [
        await safeLocationCall<void>(() => throw entry.key),
        await safeLocationCall<void>(() async => throw entry.key),
        await safeLocationStream<void>(() => throw entry.key).first,
        await safeLocationStream<void>(() => Stream.error(entry.key)).first,
      ];
      for (final result in results) {
        final failure = (result as FailureResult<void>).failure;
        expect(failure.kind, entry.value);
        expect(failure.message, isNot(contains('private')));
      }
    });
  }

  test('failed operations execute once without implicit retries', () async {
    var calls = 0;
    await safeLocationCall<void>(() {
      calls++;
      throw TimeoutException('Unavailable');
    });
    expect(calls, 1);
    var subscriptions = 0;
    await safeLocationStream<void>(() {
      subscriptions++;
      return Stream.error(TimeoutException('Unavailable'));
    }).drain<void>();
    expect(subscriptions, 1);
  });

  test(
    'subscription owns acquisition and cancellation releases the source',
    () async {
      final source = StreamController<Result<int>>();
      var calls = 0;
      final stream = safeLocationStream(() {
        calls++;
        return source.stream;
      });
      expect(calls, 0);
      expect(source.hasListener, isFalse);
      final subscription = stream.listen((_) {});
      expect(calls, 1);
      expect(source.hasListener, isTrue);
      await subscription.cancel();
      expect(source.hasListener, isFalse);
      await source.close();
    },
  );

  test('stream mapping leaves session termination to the repository', () async {
    final source = StreamController<Result<int>>();
    final values = <Result<int>>[];
    final subscription = safeLocationStream(() => source.stream)
        .listen(values.add);
    source.add(const Success(1));
    source.addError(TimeoutException('private'));
    source.add(const Success(2));
    await Future<void>.delayed(Duration.zero);
    expect((values[0] as Success<int>).value, 1);
    expect((values[1] as FailureResult<int>).failure.kind, FailureKind.timeout);
    expect((values[2] as Success<int>).value, 2);
    expect(source.hasListener, isTrue);
    await subscription.cancel();
    await source.close();
  });

  test('late future errors stay handled after stream cancellation', () async {
    final pending = Completer<Result<void>>();
    final subscription = safeLocationStream(
      () => Stream.fromFuture(pending.future),
    ).listen((_) => fail('A cancelled subscription received a result'));
    await subscription.cancel();
    pending.completeError(PlatformException(code: 'private'));
    await Future<void>.delayed(Duration.zero);
  });
}
