import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_network/src/calls/safe_api_call.dart';

/// Fetches and decodes remote data, then commits it to a local source of truth.
/// Returns success only after [save] succeeds. No cache fallback or retry runs.
/// [save] owns its storage error boundary and returns the committed value.
Future<Result<T>> networkBoundResource<Remote, T>({
  required FutureOr<Remote> Function() fetch,
  required FutureOr<Result<T>> Function(Remote data) save,
}) async {
  final response = await safeApiCall(fetch);
  return response.flatMap(save);
}
