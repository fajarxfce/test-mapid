import 'dart:async';
import 'dart:developer' as developer;

import 'package:core_common/core_common.dart';
import 'package:core_location_data/src/mappers/map_location_exception.dart';
import 'package:rxdart/rxdart.dart';

/// Runs once, preserving mapped results and translating technical failures.
/// Keep acquisition and DTO mapping inside [operation] to cover both failures.
Future<Result<T>> safeLocationCall<T>(
  FutureOr<Result<T>> Function() operation,
) async {
  try {
    return await operation();
  } on Object catch (error, stackTrace) {
    developer.log(
      'Location operation failed.',
      name: 'location.data',
      error: error,
      stackTrace: stackTrace,
    );
    return FailureResult(mapLocationException(error));
  }
}

/// Defers acquisition until subscription and maps factory/stream failures.
/// Cancellation reaches the source; the caller decides when a session ends.
Stream<Result<T>> safeLocationStream<T>(
  Stream<Result<T>> Function() operation,
) => Rx.defer(operation)
    .doOnError((error, stackTrace) {
      developer.log(
        'Location stream failed.',
        name: 'location.data',
        error: error,
        stackTrace: stackTrace,
      );
    })
    .onErrorReturnWith(
      (error, _) => FailureResult(mapLocationException(error)),
    );
