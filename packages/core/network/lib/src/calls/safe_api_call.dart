import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_network/src/mappers/network_failure_mapper.dart';

/// Executes a request once and maps transport, decoding and mapping exceptions.
/// Pass cancellation to Dio/Retrofit inside [request] when needed.
Future<Result<T>> safeApiCall<T>(FutureOr<T> Function() request) async {
  try {
    return Success(await request());
  } on Object catch (error) {
    return FailureResult(mapNetworkFailure(error));
  }
}
