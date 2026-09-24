import 'package:core_common/core_common.dart';
import 'package:core_network/src/authentication/access_credential.dart';
import 'package:core_network/src/authentication/http_authentication.dart';
import 'package:dio/dio.dart';

/// Authenticates same-origin requests unless `extra['authenticated']` is false.
/// Public endpoints and other origins never trigger session invalidation.
final class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._authentication, {required String baseUrl})
    : _origin = Uri.parse(baseUrl).origin;

  final HttpAuthentication _authentication;
  final String _origin;
  // Associate the exact credential with a request without serializing secrets
  // into Dio's extra map or retaining completed requests in a normal Map.
  final _requestCredentials = Expando<AccessCredential>();

  static const _unauthorized = Failure(
    FailureKind.unauthorized,
    'Please sign in to continue.',
  );

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['authenticated'] == false ||
        options.uri.origin != _origin) {
      handler.next(options);
      return;
    }
    final stored = await safeStorageCall(_authentication.readCredentials);
    switch (stored) {
      case FailureResult<AccessCredential?>(:final failure):
        handler.reject(DioException(requestOptions: options, error: failure));
      case Success<AccessCredential?>(value: final credential?):
        _requestCredentials[options] = credential;
        options.headers['Authorization'] = 'Bearer ${credential.token}';
        handler.next(options);
      case Success<AccessCredential?>(value: null):
        final expired = await _authentication.rejectCredentials(null);
        handler.reject(
          DioException(
            requestOptions: options,
            error: switch (expired) {
              FailureResult<void>(:final failure) => failure,
              Success<void>() => _unauthorized,
            },
          ),
        );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final credential = _requestCredentials[err.requestOptions];
    if (err.type != DioExceptionType.badResponse ||
        err.response?.statusCode != 401 ||
        credential == null) {
      handler.next(err);
      return;
    }
    final expired = await _authentication.rejectCredentials(credential);
    switch (expired) {
      case Success<void>():
        handler.next(err);
      case FailureResult<void>(:final failure):
        // Preserve a failed secure-storage cleanup instead of hiding it as 401.
        handler.next(
          err.copyWith(type: DioExceptionType.unknown, error: failure),
        );
    }
  }
}
