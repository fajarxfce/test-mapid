import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:test/test.dart';

class _CyclicDioException extends DioException {
  _CyclicDioException() : super(requestOptions: RequestOptions(path: '/me'));

  @override
  Object get error => this;
}

void main() {
  test('plain safeApiCall automatically maps every DioExceptionType', () async {
    final expected = {
      DioExceptionType.connectionTimeout: FailureKind.timeout,
      DioExceptionType.sendTimeout: FailureKind.timeout,
      DioExceptionType.receiveTimeout: FailureKind.timeout,
      DioExceptionType.transformTimeout: FailureKind.timeout,
      DioExceptionType.badCertificate: FailureKind.security,
      DioExceptionType.badResponse: FailureKind.server,
      DioExceptionType.cancel: FailureKind.cancelled,
      DioExceptionType.connectionError: FailureKind.network,
      DioExceptionType.unknown: FailureKind.invalidResponse,
    };
    expect(expected.keys.toSet(), DioExceptionType.values.toSet());
    for (final type in DioExceptionType.values) {
      final options = RequestOptions(path: '/resource');
      final result = await safeApiCall<void>(() async {
        throw DioException(
          requestOptions: options,
          type: type,
          response: type == DioExceptionType.badResponse
              ? Response<Object>(requestOptions: options, statusCode: 503)
              : null,
          error: type == DioExceptionType.unknown
              ? const FormatException('invalid JSON')
              : null,
        );
      });
      expect(
        (result as FailureResult<void>).failure.kind,
        expected[type],
        reason: type.name,
      );
    }
  });

  test('every HTTP client/server status has a classified fallback', () {
    final options = RequestOptions(path: '/resource');
    Failure classify(int? status) => mapNetworkFailure(
      DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: status == null
            ? null
            : Response<Object>(requestOptions: options, statusCode: status),
      ),
    );
    final specific = {
      400: FailureKind.validation,
      401: FailureKind.unauthorized,
      403: FailureKind.forbidden,
      404: FailureKind.notFound,
      408: FailureKind.timeout,
      409: FailureKind.conflict,
      422: FailureKind.validation,
      429: FailureKind.rateLimited,
    };
    for (var status = 400; status <= 499; status++) {
      expect(
        classify(status).kind,
        specific[status] ?? FailureKind.request,
        reason: '$status',
      );
    }
    for (var status = 500; status <= 599; status++) {
      expect(classify(status).kind, FailureKind.server, reason: '$status');
    }
    for (final status in [null, 200, 301, 399, 600]) {
      expect(classify(status).kind, FailureKind.invalidResponse);
    }
  });

  test(
    'transport failure types take precedence over attached HTTP metadata',
    () {
      final options = RequestOptions(path: '/resource');
      for (final entry in {
        DioExceptionType.receiveTimeout: FailureKind.timeout,
        DioExceptionType.transformTimeout: FailureKind.timeout,
        DioExceptionType.badCertificate: FailureKind.security,
        DioExceptionType.cancel: FailureKind.cancelled,
      }.entries) {
        final failure = mapNetworkFailure(
          DioException(
            requestOptions: options,
            type: entry.key,
            response: Response<Object>(
              requestOptions: options,
              statusCode: 401,
            ),
          ),
        );
        expect(failure.kind, entry.value);
      }
    },
  );

  test('unknown Dio wrappers inspect nested causes and terminate cycles', () {
    final options = RequestOptions(path: '/resource');
    final inner = DioException(
      requestOptions: options,
      error: TimeoutException('private'),
    );
    expect(
      mapNetworkFailure(DioException(requestOptions: options, error: inner))
          .kind,
      FailureKind.timeout,
    );
    expect(
      mapNetworkFailure(DioException(requestOptions: options)).kind,
      FailureKind.unexpected,
    );
    expect(
      mapNetworkFailure(
        DioException(requestOptions: options, error: StateError('private')),
      ).kind,
      FailureKind.unexpected,
    );
    expect(
      mapNetworkFailure(_CyclicDioException()).kind,
      FailureKind.unexpected,
    );
  });

  for (final entry in {
    400: FailureKind.validation,
    401: FailureKind.unauthorized,
    403: FailureKind.forbidden,
    404: FailureKind.notFound,
    408: FailureKind.timeout,
    409: FailureKind.conflict,
    422: FailureKind.validation,
    429: FailureKind.rateLimited,
    500: FailureKind.server,
    503: FailureKind.server,
  }.entries) {
    test(
      'HTTP ${entry.key} maps to ${entry.value.name} without server details',
      () {
        final options = RequestOptions(path: '/private?token=secret');
        final failure = mapNetworkFailure(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            message: 'private exception',
            response: Response<Object>(
              requestOptions: options,
              statusCode: entry.key,
              data: 'private response',
            ),
          ),
        );
        expect(failure.kind, entry.value);
        expect(failure.message, isNot(contains('private')));
        expect(failure.message, isNot(contains('secret')));
      },
    );
  }

  test('transport failure kinds remain distinct', () {
    final options = RequestOptions(path: '/me');
    for (final entry in {
      DioExceptionType.connectionTimeout: FailureKind.timeout,
      DioExceptionType.sendTimeout: FailureKind.timeout,
      DioExceptionType.receiveTimeout: FailureKind.timeout,
      DioExceptionType.connectionError: FailureKind.network,
      DioExceptionType.badCertificate: FailureKind.security,
      DioExceptionType.cancel: FailureKind.cancelled,
    }.entries) {
      expect(
        mapNetworkFailure(
          DioException(requestOptions: options, type: entry.key),
        ).kind,
        entry.value,
      );
    }
    expect(
      mapNetworkFailure(TimeoutException('private')).kind,
      FailureKind.timeout,
    );
  });

  test(
    'decoding and mapping exceptions are caught by the API boundary',
    () async {
      final checked = CheckedFromJsonException(
        {'secret': 'private'},
        'id',
        'User',
        'bad value',
      );
      for (final operation in <String Function()>[
        () => throw const FormatException('private JSON'),
        () => throw checked,
        () {
          final Object value = 42;
          return value as String;
        },
        () => throw DioException(
          requestOptions: RequestOptions(path: '/me'),
          error: checked,
        ),
      ]) {
        final result = await safeApiCall(() => operation());
        final failure = (result as FailureResult<String>).failure;
        expect(failure.kind, FailureKind.invalidResponse);
        expect(failure.message, isNot(contains('private')));
      }
    },
  );

  test('local infrastructure failures retain their original kind', () {
    const failure = Failure(FailureKind.storage, 'Storage unavailable');
    final error = DioException(
      requestOptions: RequestOptions(path: '/me'),
      error: failure,
    );
    expect(mapNetworkFailure(error), same(failure));
    expect(
      mapNetworkFailure(StateError('private bug')).kind,
      FailureKind.unexpected,
    );
  });

  test('classifies timeout, authorization and server failures', () {
    final request = RequestOptions(path: '/me');
    expect(
      mapNetworkFailure(
        DioException(
          requestOptions: request,
          type: DioExceptionType.connectionTimeout,
        ),
      ).kind,
      FailureKind.timeout,
    );
    expect(
      mapNetworkFailure(
        DioException(
          requestOptions: request,
          response: Response<Object>(requestOptions: request, statusCode: 401),
        ),
      ).kind,
      FailureKind.unauthorized,
    );
    expect(
      mapNetworkFailure(
        DioException(
          requestOptions: request,
          type: DioExceptionType.badResponse,
          response: Response<Object>(requestOptions: request, statusCode: 503),
        ),
      ).kind,
      FailureKind.server,
    );
  });
}
