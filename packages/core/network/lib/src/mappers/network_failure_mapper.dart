import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_network/src/mappers/platform_exception_mapper_stub.dart'
    if (dart.library.io) 'package:core_network/src/mappers/platform_exception_mapper_io.dart'
    as platform;
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

const _timeout = Failure(
  FailureKind.timeout,
  'The request timed out. Please try again.',
);
const _network = Failure(
  FailureKind.network,
  'Unable to connect. Check your connection.',
);
const _unexpected = Failure(
  FailureKind.unexpected,
  'Something went wrong. Please try again.',
);

/// Converts Dio, nested transport and decoding errors into domain failures.
Failure mapNetworkFailure(Object error) =>
    _mapError(error, Set<Object>.identity());

Failure _mapError(Object error, Set<Object> visited) {
  // Custom adapters/interceptors can wrap errors, including cyclic causes.
  if (visited.length >= 16 || !visited.add(error)) return _unexpected;
  return switch (error) {
    Failure() => error,
    DioException() => _mapDio(error, visited),
    TimeoutException() => _timeout,
    FormatException() ||
    CheckedFromJsonException() ||
    TypeError() => const Failure(
      FailureKind.invalidResponse,
      'The service returned an invalid response.',
    ),
    _ => platform.mapPlatformException(error) ?? _unexpected,
  };
}

// Exhaustive: adding a DioExceptionType requires updating this mapping.
Failure _mapDio(DioException error, Set<Object> visited) =>
    switch (error.type) {
      DioExceptionType.connectionTimeout => _timeout,
      DioExceptionType.sendTimeout => _timeout,
      DioExceptionType.receiveTimeout => _timeout,
      DioExceptionType.transformTimeout => _timeout,
      DioExceptionType.badCertificate => const Failure(
        FailureKind.security,
        'A secure connection could not be established.',
      ),
      DioExceptionType.badResponse => _mapHttpStatus(
        error.response?.statusCode,
      ),
      DioExceptionType.cancel => const Failure(
        FailureKind.cancelled,
        'The request was cancelled.',
      ),
      DioExceptionType.connectionError => _mapCause(error, visited) ?? _network,
      DioExceptionType.unknown =>
        _mapCause(error, visited) ??
            (error.response == null
                ? _unexpected
                : _mapHttpStatus(error.response?.statusCode)),
    };

Failure? _mapCause(DioException error, Set<Object> visited) {
  final cause = error.error;
  if (cause == null) return null;
  final failure = _mapError(cause, visited);
  // Preserve explicit domain failures, including unexpected ones from adapters.
  if (cause is Failure || failure.kind != FailureKind.unexpected) {
    return failure;
  }
  return null;
}

Failure _mapHttpStatus(int? status) => switch (status) {
  400 || 422 => const Failure(
    FailureKind.validation,
    'The submitted information was rejected.',
  ),
  401 => const Failure(
    FailureKind.unauthorized,
    'Your credentials or session are no longer valid.',
  ),
  403 => const Failure(
    FailureKind.forbidden,
    'You do not have permission to perform this action.',
  ),
  404 => const Failure(
    FailureKind.notFound,
    'The requested resource was not found.',
  ),
  408 => _timeout,
  409 => const Failure(
    FailureKind.conflict,
    'The resource changed. Refresh and try again.',
  ),
  429 => const Failure(
    FailureKind.rateLimited,
    'Too many requests. Please try again later.',
  ),
  int value when value >= 400 && value <= 499 => const Failure(
    FailureKind.request,
    'The server rejected the request.',
  ),
  int value when value >= 500 && value <= 599 => const Failure(
    FailureKind.server,
    'The service is unavailable. Please try again.',
  ),
  _ => const Failure(
    FailureKind.invalidResponse,
    'The service returned an unexpected HTTP response.',
  ),
};
