import 'dart:async';

import 'package:core_common/src/failures/failure.dart';

part 'failure_result.dart';
part 'success.dart';

sealed class Result<T> {
  const Result();

  /// Continues only on success. I/O in [next] must use its own safe boundary.
  Future<Result<R>> flatMap<R>(
    FutureOr<Result<R>> Function(T value) next,
  ) async => switch (this) {
    Success<T>(:final value) => await next(value),
    FailureResult<T>(:final failure) => FailureResult<R>(failure),
  };
}
