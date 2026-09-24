import 'dart:async';

import 'package:core_common/src/failures/failure.dart';
import 'package:core_common/src/failures/failure_kind.dart';
import 'package:core_common/src/result/result.dart';

/// Converts storage errors into a domain failure without exposing plugin errors.
Future<Result<T>> safeStorageCall<T>(
  FutureOr<T> Function() operation, {
  String message = 'Unable to access local storage. Please try again.',
}) async {
  try {
    return Success(await operation());
  } on Object {
    return FailureResult(Failure(FailureKind.storage, message));
  }
}
