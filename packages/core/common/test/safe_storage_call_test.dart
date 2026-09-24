import 'package:core_common/core_common.dart';
import 'package:test/test.dart';

void main() {
  test('supports sync, async, nullable and void storage operations', () async {
    expect((await safeStorageCall(() => 42) as Success<int>).value, 42);
    expect(
      (await safeStorageCall(() async => 'saved') as Success<String>).value,
      'saved',
    );
    expect(
      (await safeStorageCall<String?>(() => null) as Success<String?>).value,
      isNull,
    );
    expect(await safeStorageCall<void>(() async {}), isA<Success<void>>());
  });

  test(
    'sync and async storage failures expose only the chosen message',
    () async {
      for (final operation in <Future<String> Function()>[
        () => throw StateError('secret plugin details'),
        () async => throw StateError('secret plugin details'),
      ]) {
        final result = await safeStorageCall(
          operation,
          message: 'Storage unavailable',
        );
        final failure = (result as FailureResult<String>).failure;
        expect(failure.kind, FailureKind.storage);
        expect(failure.message, 'Storage unavailable');
      }
    },
  );

  test(
    'failed I/O short-circuits downstream work and preserves failure identity',
    () async {
      final result = await safeStorageCall<int>(
        () => throw StateError('failed'),
      );
      var called = false;
      final next = await result.flatMap<String>((value) {
        called = true;
        return Success('$value');
      });
      expect(called, isFalse);
      expect(
        (next as FailureResult<String>).failure,
        same((result as FailureResult<int>).failure),
      );
    },
  );

  test('successful results compose async operations; callback errors remain visible', () async {
    final result = await const Success(2)
        .flatMap((value) async => Success(value * 3));
    expect((result as Success<int>).value, 6);
    await expectLater(
      const Success(2)
          .flatMap<void>((_) => throw StateError('programming error')),
      throwsStateError,
    );
  });
}
