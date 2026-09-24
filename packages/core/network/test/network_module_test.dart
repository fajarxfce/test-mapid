import 'dart:typed_data';

import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart' show GetItHelper;
import 'package:test/test.dart';

import 'support/fake_http_authentication.dart';

class _RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  int status = 200;
  bool closed = false;
  bool forceClosed = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{}',
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {
    closed = true;
    forceClosed = force;
  }
}

void main() {
  late GetIt container;
  late _RecordingAdapter adapter;
  late List<String> logs;

  setUp(() async {
    container = GetIt.asNewInstance();
    adapter = _RecordingAdapter();
    logs = [];
    container.registerSingleton(
      BaseOptions(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 2),
        receiveTimeout: const Duration(seconds: 3),
        sendTimeout: const Duration(seconds: 4),
        contentType: Headers.jsonContentType,
      ),
      instanceName: mainApi,
    );
    container.registerSingleton(
      SafeLoggingInterceptor(logs.add),
      instanceName: mainApi,
    );
    container.registerSingleton<HttpAuthentication>(
      FakeHttpAuthentication('private-token'),
      instanceName: mainApi,
    );
    container.registerSingleton<HttpClientAdapter>(
      adapter,
      instanceName: mainApi,
    );
    await CoreNetworkPackageModule().init(GetItHelper(container));
  });
  tearDown(() => container.reset());

  test('generated providers share the configured client and transport', () {
    final dio = container<Dio>(instanceName: mainApi);
    expect(container<Dio>(instanceName: mainApi), same(dio));
    expect(container.isRegistered<Dio>(), isFalse);
    expect(dio.httpClientAdapter, same(adapter));
    expect(dio.options, same(container<BaseOptions>(instanceName: mainApi)));
    expect(dio.options.baseUrl, 'https://api.example.com');
    expect(dio.options.connectTimeout, const Duration(seconds: 2));
    expect(dio.options.receiveTimeout, const Duration(seconds: 3));
    expect(dio.options.sendTimeout, const Duration(seconds: 4));
    expect(dio.options.contentType, Headers.jsonContentType);
  });

  test('credentials are attached only to authenticated API requests', () async {
    final dio = container<Dio>(instanceName: mainApi);
    await dio.get<Object>('/auth/me');
    await dio.post<Object>(
      '/auth/login',
      options: Options(extra: {'authenticated': false}),
    );
    await dio.post<Object>(
      '/auth/oauth/google/exchange',
      options: Options(extra: {'authenticated': false}),
    );
    await dio.post<Object>(
      'https://api.example.com/auth/login?source=test',
      options: Options(extra: {'authenticated': false}),
    );
    await dio.get<Object>('https://other.example.com/auth/me');
    await dio.get<Object>('https://api.example.com:8443/auth/me');
    expect(
      adapter.requests.first.headers['Authorization'],
      'Bearer private-token',
    );
    for (final request in adapter.requests.skip(1)) {
      expect(request.headers, isNot(contains('Authorization')));
    }
  });

  test('success and error logs omit request and credential details', () async {
    final dio = container<Dio>(instanceName: mainApi);
    await dio.post<Object>(
      '/auth/login?email=private@example.com',
      data: {'password': 'private-password'},
    );
    adapter.status = 401;
    await expectLater(
      dio.get<Object>('/auth/me'),
      throwsA(isA<DioException>()),
    );
    expect(logs, [
      'HTTP POST',
      'HTTP 200',
      'HTTP GET',
      'HTTP failure badResponse 401',
    ]);
  });

  test(
    'named clients isolate configuration, credentials, logs and disposal',
    () async {
      const uploadApi = 'uploadApi';
      final uploadAdapter = _RecordingAdapter()..status = 429;
      final uploadLogs = <String>[];
      final uploadOptions = BaseOptions(
        baseUrl: 'https://uploads.example.com',
        sendTimeout: const Duration(seconds: 30),
      );
      final uploadClient = Dio(uploadOptions)
        ..httpClientAdapter = uploadAdapter
        ..interceptors.addAll([
          AuthInterceptor(
            FakeHttpAuthentication('upload-token'),
            baseUrl: uploadOptions.baseUrl,
          ),
          SafeLoggingInterceptor(uploadLogs.add),
        ]);
      container.registerSingleton<Dio>(
        uploadClient,
        instanceName: uploadApi,
        dispose: (client) => client.close(force: true),
      );
      final mainClient = container<Dio>(instanceName: mainApi);
      final secondaryClient = container<Dio>(instanceName: uploadApi);
      expect(mainClient, isNot(same(secondaryClient)));
      expect(mainClient.options, isNot(same(secondaryClient.options)));

      final mainResult = await safeApiCall(
        () => mainClient.get<Object>('/auth/me'),
      );
      final uploadResult = await safeApiCall(
        () => secondaryClient.get<Object>('/files'),
      );
      expect(mainResult, isA<Success<Response<Object>>>());
      expect(
        (uploadResult as FailureResult<Response<Object>>).failure.kind,
        FailureKind.rateLimited,
      );
      expect(adapter.requests.single.uri.host, 'api.example.com');
      expect(adapter.requests.single.sendTimeout, const Duration(seconds: 4));
      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer private-token',
      );
      expect(uploadAdapter.requests.single.uri.host, 'uploads.example.com');
      expect(
        uploadAdapter.requests.single.sendTimeout,
        const Duration(seconds: 30),
      );
      expect(
        uploadAdapter.requests.single.headers['Authorization'],
        'Bearer upload-token',
      );
      expect(logs, ['HTTP GET', 'HTTP 200']);
      expect(uploadLogs, ['HTTP GET', 'HTTP failure badResponse 429']);

      uploadAdapter.status = 200;
      await mainClient.get<Object>('https://uploads.example.com/auth/me');
      await secondaryClient.get<Object>('https://api.example.com/auth/me');
      expect(adapter.requests.last.headers, isNot(contains('Authorization')));
      expect(
        uploadAdapter.requests.last.headers,
        isNot(contains('Authorization')),
      );

      await container.resetLazySingleton<Dio>(instanceName: mainApi);
      expect(adapter.forceClosed, isTrue);
      expect(uploadAdapter.closed, isFalse);
      expect(
        await safeApiCall(() => secondaryClient.get<Object>('/files')),
        isA<Success<Response<Object>>>(),
      );
      await container.reset();
      expect(uploadAdapter.forceClosed, isTrue);
    },
  );

  test(
    'reset runs the generated Dio disposer and closes its transport',
    () async {
      container<Dio>(instanceName: mainApi);
      expect(adapter.closed, isFalse);
      await container.reset();
      expect(adapter.closed, isTrue);
      expect(adapter.forceClosed, isTrue);
    },
  );
}
