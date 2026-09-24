import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  test(
    'returns the committed value only after persistence completes',
    () async {
      final saving = Completer<void>();
      final release = Completer<void>();
      final calls = <String>[];
      var completed = false;
      final pending =
          networkBoundResource<int, String>(
            fetch: () {
              calls.add('fetch');
              return 42;
            },
            save: (data) async {
              calls.add('save:$data');
              saving.complete();
              await release.future;
              return Success('saved:$data');
            },
          ).then((result) {
            completed = true;
            return result;
          });
      await saving.future;
      expect(completed, isFalse);
      release.complete();
      expect(((await pending) as Success<String>).value, 'saved:42');
      expect(calls, ['fetch', 'save:42']);
    },
  );

  test('request and decoding failures never reach persistence', () async {
    final options = RequestOptions(path: '/login');
    final failures = <Object, FailureKind>{
      DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<Object>(requestOptions: options, statusCode: 401),
      ): FailureKind.unauthorized,
      const FormatException('invalid session'): FailureKind.invalidResponse,
    };
    for (final entry in failures.entries) {
      var saved = false;
      final result = await networkBoundResource<void, void>(
        fetch: () async => throw entry.key,
        save: (_) {
          saved = true;
          return const Success(null);
        },
      );
      expect(saved, isFalse);
      expect((result as FailureResult<void>).failure.kind, entry.value);
    }
  });

  test(
    'persistence failures retain their identity without replaying fetch',
    () async {
      const failure = Failure(FailureKind.storage, 'Storage unavailable');
      var requests = 0;
      final result = await networkBoundResource<int, String>(
        fetch: () => ++requests,
        save: (_) async => const FailureResult(failure),
      );
      expect((result as FailureResult<String>).failure, same(failure));
      expect(requests, 1);
    },
  );
}
