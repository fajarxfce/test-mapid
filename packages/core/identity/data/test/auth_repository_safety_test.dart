import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:core_testing/core_testing.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:identity_data/identity_data.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart' show GetItHelper;
import 'package:test/test.dart';

class _MockCredentials extends Mock implements CredentialStore {}

Future<({IdentityRepository repository, Dio dio, DemoAdapter adapter})> _create(
  CredentialStore credentials,
) async {
  final container = GetIt.asNewInstance();
  addTearDown(container.reset);
  final adapter = DemoAdapter(latency: Duration.zero);
  container.registerSingleton<CredentialStore>(credentials);
  container.registerSingleton(
    const AppEnvironment(label: 'test', isDemo: true),
  );
  container.registerSingleton(
    OAuthConfiguration(apiOrigin: Uri.parse('https://demo.invalid')),
  );
  container.registerSingleton(
    BaseOptions(baseUrl: 'https://demo.invalid'),
    instanceName: mainApi,
  );
  container.registerSingleton(
    SafeLoggingInterceptor(null),
    instanceName: mainApi,
  );
  container.registerSingleton<HttpClientAdapter>(
    adapter,
    instanceName: mainApi,
  );
  await CoreNetworkPackageModule().init(GetItHelper(container));
  await IdentityDataPackageModule().init(GetItHelper(container));
  return (
    repository: container<IdentityRepository>(),
    dio: container<Dio>(instanceName: mainApi),
    adapter: adapter,
  );
}

Future<Result<User>> _login(IdentityRepository repository) =>
    repository.login(email: 'demo@example.com', password: 'Demo123!');

void main() {
  for (final payload in [
    {
      'access_token': 'token',
      'user': {'id': 42},
    },
    {'access_token': '', 'user': DemoAdapter.user},
    {'access_token': '   ', 'user': DemoAdapter.user},
  ]) {
    test(
      'invalid login payload never persists credentials: $payload',
      () async {
        final credentials = FakeCredentialStore();
        final fixture = await _create(credentials);
        fixture.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response<Object>(
                  requestOptions: options,
                  statusCode: 200,
                  data: payload,
                ),
              );
            },
          ),
        );
        final result = await _login(fixture.repository);
        expect(
          (result as FailureResult<User>).failure.kind,
          FailureKind.invalidResponse,
        );
        expect(credentials.token, isNull);
        expect(fixture.repository.session.user, isNull);
      },
    );
  }

  test(
    'a stored-token read failure is returned without attempting cleanup',
    () async {
      final credentials = _MockCredentials();
      when(credentials.read).thenThrow(StateError('private keychain failure'));
      final fixture = await _create(credentials);
      final result = await fixture.repository.restoreSession();
      final failure = (result as FailureResult<User?>).failure;
      expect(failure.kind, FailureKind.storage);
      expect(failure.message, isNot(contains('private')));
      verifyNever(credentials.clear);
    },
  );

  test(
    'credential interceptor failures preserve storage classification',
    () async {
      final credentials = _MockCredentials();
      var reads = 0;
      when(credentials.read).thenAnswer((_) async {
        if (++reads == 1) return 'demo-access-token';
        throw StateError('keychain locked while attaching headers');
      });
      final fixture = await _create(credentials);
      final result = await fixture.repository.restoreSession();
      expect(
        (result as FailureResult<User?>).failure.kind,
        FailureKind.storage,
      );
      expect(reads, 2);
      verifyNever(credentials.clear);
    },
  );

  test('failed credential cleanup after a 401 is visible and removes in-memory auth', () async {
    final credentials = _MockCredentials();
    String? stored;
    when(credentials.read).thenAnswer((_) async => stored);
    when(() => credentials.write(any())).thenAnswer(
      (invocation) async =>
          stored = invocation.positionalArguments.first as String,
    );
    when(credentials.clear).thenThrow(StateError('keychain locked'));
    final fixture = await _create(credentials);
    expect(await _login(fixture.repository), isA<Success<User>>());
    fixture.adapter.expireSession = true;
    final result = await fixture.repository.restoreSession();
    expect((result as FailureResult<User?>).failure.kind, FailureKind.storage);
    expect(fixture.repository.session.user, isNull);
    expect(stored, 'demo-access-token');
  });

  test('401 on any protected endpoint expires the session without a restore use case', () async {
    final credentials = FakeCredentialStore();
    final fixture = await _create(credentials);
    await _login(fixture.repository);
    fixture.adapter.expireSession = true;
    final result = await safeApiCall(() => fixture.dio.get<Object>('/auth/me'));
    expect(
      (result as FailureResult<Response<Object>>).failure.kind,
      FailureKind.unauthorized,
    );
    expect(fixture.repository.session, isA<SessionUnauthenticated>());
    expect(credentials.token, isNull);
  });

  test('public login failure leaves the existing session intact', () async {
    final credentials = FakeCredentialStore();
    final fixture = await _create(credentials);
    await _login(fixture.repository);
    final result = await fixture.repository.login(
      email: 'demo@example.com',
      password: 'incorrect',
    );
    expect(
      (result as FailureResult<User>).failure.kind,
      FailureKind.unauthorized,
    );
    expect(fixture.repository.session, isA<SessionAuthenticated>());
    expect(credentials.token, 'demo-access-token');
  });

  test('transient session failures preserve credentials for retry', () async {
    final credentials = FakeCredentialStore();
    final fixture = await _create(credentials);
    await _login(fixture.repository);
    fixture.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.receiveTimeout,
            ),
          );
        },
      ),
    );
    final result = await fixture.repository.restoreSession();
    expect((result as FailureResult<User?>).failure.kind, FailureKind.timeout);
    expect(credentials.token, 'demo-access-token');
    expect(fixture.repository.session.user, isNotNull);
  });

  test("a protected request's stale 401 cannot clear a newer login with the same token text", () async {
    final credentials = FakeCredentialStore();
    final fixture = await _create(credentials);
    await _login(fixture.repository);
    final held =
        Completer<
          ({RequestOptions options, RequestInterceptorHandler handler})
        >();
    fixture.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path == '/private/profile') {
            held.complete((options: options, handler: handler));
          } else {
            handler.next(options);
          }
        },
      ),
    );
    final pending = safeApiCall(
      () => fixture.dio.get<Object>('/private/profile'),
    );
    final request = await held.future;
    expect(await _login(fixture.repository), isA<Success<User>>());
    request.handler.reject(
      DioException(
        requestOptions: request.options,
        type: DioExceptionType.badResponse,
        response: Response<Object>(
          requestOptions: request.options,
          statusCode: 401,
        ),
      ),
      true,
    );
    expect(
      ((await pending) as FailureResult<Response<Object>>).failure.kind,
      FailureKind.unauthorized,
    );
    expect(credentials.token, 'demo-access-token');
    expect(fixture.repository.session.user, isNotNull);
  });

  test(
    'logout during an unfinished credential write rolls back the late token',
    () async {
      final credentials = _MockCredentials();
      final writing = Completer<void>();
      final releaseWrite = Completer<void>();
      String? stored;
      when(credentials.read).thenAnswer((_) async => stored);
      when(credentials.clear).thenAnswer((_) async {
        stored = null;
      });
      when(() => credentials.write(any())).thenAnswer((invocation) async {
        writing.complete();
        await releaseWrite.future;
        stored = invocation.positionalArguments.first as String;
      });
      final fixture = await _create(credentials);
      final pending = _login(fixture.repository);
      await writing.future;
      var logoutCompleted = false;
      final logout = fixture.repository.logout().then((result) {
        logoutCompleted = true;
        return result;
      });
      expect(fixture.repository.session.user, isNull);
      await Future<void>.delayed(Duration.zero);
      expect(logoutCompleted, isFalse);
      releaseWrite.complete();
      expect(await logout, isA<Success<void>>());
      expect(
        ((await pending) as FailureResult<User>).failure.kind,
        FailureKind.cancelled,
      );
      expect(stored, isNull);
      expect(fixture.repository.session.user, isNull);
    },
  );
}
