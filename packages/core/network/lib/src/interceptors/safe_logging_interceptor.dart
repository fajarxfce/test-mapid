import 'package:dio/dio.dart';

final class SafeLoggingInterceptor extends Interceptor {
  SafeLoggingInterceptor(this._log);
  final void Function(String message)? _log;
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log?.call('HTTP ${options.method}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log?.call('HTTP ${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // No URL, headers, bodies, tokens, passwords or exception details.
    _log?.call(
      'HTTP failure ${err.type.name} ${err.response?.statusCode ?? '-'}',
    );
    handler.next(err);
  }
}
