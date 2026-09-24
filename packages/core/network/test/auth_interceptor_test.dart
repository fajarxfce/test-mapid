import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

import 'support/fake_http_authentication.dart';

void main() {
  late Dio dio;
  late FakeHttpAuthentication authentication;
  late List<RequestOptions> requests;
  var status = 200;
  setUp(() {
    status = 200;
    requests = [];
    authentication = FakeHttpAuthentication('private-token');
    dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
      ..interceptors.add(
        AuthInterceptor(authentication, baseUrl: 'https://api.example.com'),
      )
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            final response = Response<Object>(
              requestOptions: options,
              statusCode: status,
            );
            if (status >= 400) {
              handler.reject(
                DioException.badResponse(
                  statusCode: status,
                  requestOptions: options,
                  response: response,
                ),
                true,
              );
            } else {
              handler.resolve(response);
            }
          },
        ),
      );
  });
  tearDown(() => dio.close(force: true));

  test(
    'protected request without credentials fails before transport',
    () async {
      authentication.credential = null;
      final result = await safeApiCall(() => dio.get<Object>('/private'));
      expect(
        (result as FailureResult<Response<Object>>).failure.kind,
        FailureKind.unauthorized,
      );
      expect(requests, isEmpty);
      expect(authentication.rejected, [null]);
    },
  );

  test('public request works without credentials and its 401 does not expire a session', () async {
    authentication.credential = null;
    status = 401;
    final result = await safeApiCall(
      () => dio.post<Object>(
        '/login',
        options: Options(extra: {'authenticated': false}),
      ),
    );
    expect(
      (result as FailureResult<Response<Object>>).failure.kind,
      FailureKind.unauthorized,
    );
    expect(requests.single.headers, isNot(contains('Authorization')));
    expect(authentication.rejected, isEmpty);
  });

  test(
    'protected 401 reports the exact credential used by the request',
    () async {
      final credential = authentication.credential;
      status = 401;
      await safeApiCall(() => dio.get<Object>('/any/protected/resource'));
      expect(authentication.rejected, [same(credential)]);
      expect(requests.single.headers['Authorization'], 'Bearer private-token');
    },
  );

  test(
    'foreign origin 401 never receives credentials or expires this client',
    () async {
      status = 401;
      await safeApiCall(
        () => dio.get<Object>('https://other.example.com/private'),
      );
      expect(requests.single.headers, isNot(contains('Authorization')));
      expect(authentication.rejected, isEmpty);
    },
  );

  test('403 and server errors do not invalidate credentials', () async {
    for (final code in [403, 429, 500]) {
      status = code;
      await safeApiCall(() => dio.get<Object>('/private'));
    }
    expect(authentication.rejected, isEmpty);
    expect(authentication.credential, isNotNull);
  });

  test('failed cleanup preserves storage classification', () async {
    status = 401;
    authentication.rejectionResult = const FailureResult(
      Failure(FailureKind.storage, 'Storage unavailable'),
    );
    final result = await safeApiCall(() => dio.get<Object>('/private'));
    expect(
      (result as FailureResult<Response<Object>>).failure.kind,
      FailureKind.storage,
    );
  });

  test(
    'failed credential reads neither send requests nor trigger logout',
    () async {
      authentication.readError = StateError('private platform details');
      final result = await safeApiCall(() => dio.get<Object>('/private'));
      expect(
        (result as FailureResult<Response<Object>>).failure.kind,
        FailureKind.storage,
      );
      expect(result.failure.message, isNot(contains('private')));
      expect(requests, isEmpty);
      expect(authentication.rejected, isEmpty);
    },
  );
}
