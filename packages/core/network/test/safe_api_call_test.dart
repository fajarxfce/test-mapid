import 'dart:async';
import 'dart:typed_data';

import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

class _PendingAdapter implements HttpClientAdapter {
  final started = Completer<void>();
  final response = Completer<ResponseBody>();
  final cancelled = Completer<void>();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    started.complete();
    unawaited(cancelFuture?.then((_) => cancelled.complete()));
    return response.future;
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'supports ordinary callbacks with sync, async, nullable and void results',
    () async {
      final result = await safeApiCall(() => 42);
      expect((result as Success<int>).value, 42);
      expect(
        (await safeApiCall(() async => 'value') as Success<String>).value,
        'value',
      );
      expect(
        (await safeApiCall<String?>(() => null) as Success<String?>).value,
        isNull,
      );
      expect(await safeApiCall<void>(() async {}), isA<Success<void>>());
    },
  );

  test(
    'maps synchronous and asynchronous exceptions through the same boundary',
    () async {
      for (final request in <FutureOr<void> Function()>[
        () => throw TimeoutException('private request'),
        () async {
          await Future<void>.delayed(Duration.zero);
          throw TimeoutException('private request');
        },
      ]) {
        final result = await safeApiCall(request);
        final failure = (result as FailureResult<void>).failure;
        expect(failure.kind, FailureKind.timeout);
        expect(failure.message, isNot(contains('private')));
      }
    },
  );

  test(
    'executes each request once, including transient reads and mutations',
    () async {
      for (final method in [
        'GET',
        'HEAD',
        'OPTIONS',
        'POST',
        'PUT',
        'PATCH',
        'DELETE',
      ]) {
        var attempts = 0;
        final options = RequestOptions(path: '/resource', method: method);
        final result = await safeApiCall<void>(() {
          attempts++;
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response<Object>(
              requestOptions: options,
              statusCode: 503,
            ),
          );
        });
        expect(attempts, 1, reason: method);
        expect(
          (result as FailureResult<void>).failure.kind,
          FailureKind.server,
        );
      }
    },
  );

  test('Dio rejects a pre-cancelled token before reaching transport', () async {
    final adapter = _PendingAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    addTearDown(() => dio.close(force: true));
    final token = CancelToken()..cancel('private reason');
    final result = await safeApiCall(
      () => dio.get<Object>('/pending', cancelToken: token),
    );
    expect(adapter.started.isCompleted, isFalse);
    final failure = (result as FailureResult<Response<Object>>).failure;
    expect(failure.kind, FailureKind.cancelled);
    expect(failure.message, isNot(contains('private')));
  });

  test(
    'Dio cancellation reaches transport and late adapter errors stay handled',
    () async {
      final adapter = _PendingAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      addTearDown(() => dio.close(force: true));
      final token = CancelToken();
      final pending = safeApiCall(
        () => dio.get<Object>('/pending', cancelToken: token),
      );
      await adapter.started.future;
      token.cancel();
      final result = await pending.timeout(const Duration(seconds: 1));
      await adapter.cancelled.future;
      expect(
        (result as FailureResult<Response<Object>>).failure.kind,
        FailureKind.cancelled,
      );
      adapter.response.completeError(StateError('late adapter error'));
      await Future<void>.delayed(Duration.zero);
    },
  );
}
