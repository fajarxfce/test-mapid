import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:core_testing/core_testing.dart';
import 'package:dio/dio.dart';
import 'package:identity_data/identity_data.dart';
import 'package:identity_data/src/datasources/demo/demo_oauth_browser.dart';
import 'package:identity_data/src/datasources/remote/api_auth_remote_data_source.dart';
import 'package:identity_data/src/datasources/remote/browser_oauth_remote_data_source.dart';
import 'package:identity_data/src/oauth/oauth_attempt.dart';
import 'package:identity_data/src/services/auth_api.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:test/test.dart';

import 'support/callback_oauth_browser.dart';

void main() {
  late FakeCredentialStore credentials;
  late Dio dio;
  late PersistentIdentitySession local;
  late DemoOAuthBrowser browser;
  late OAuthConfiguration config;
  late List<RequestOptions> requests;
  late List<String> logs;
  setUp(() {
    credentials = FakeCredentialStore();
    local = PersistentIdentitySession(credentials);
    requests = [];
    logs = [];
    dio = Dio(BaseOptions(baseUrl: 'https://demo.invalid'))
      ..httpClientAdapter = DemoAdapter(latency: Duration.zero)
      ..interceptors.add(
        AuthInterceptor(local, baseUrl: 'https://demo.invalid'),
      )
      ..interceptors.add(SafeLoggingInterceptor(logs.add))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            handler.next(options);
          },
        ),
      );
    browser = DemoOAuthBrowser(dio);
    config = OAuthConfiguration(
      apiOrigin: Uri.parse('https://demo.invalid'),
      redirectUri: Uri.parse('dev.example.app.oauth://oauth/callback'),
      providers: IdentityProvider.values.toSet(),
    );
  });
  tearDown(() async {
    await local.dispose();
    dio.close(force: true);
  });
  RemoteIdentityRepository repository({
    OAuthBrowser? overrideBrowser,
    OAuthConfiguration? configuration,
  }) => RemoteIdentityRepository(
    ApiAuthRemoteDataSource(AuthApi(dio)),
    local,
    BrowserOAuthRemoteDataSource(
      AuthApi(dio),
      overrideBrowser ?? browser,
      configuration ?? config,
    ),
  );

  for (final provider in IdentityProvider.values) {
    test(
      '${provider.name} exchanges a code, stores a session and restores it',
      () async {
        credentials.token = 'old-secret-token';
        final repo = repository();
        final result = await repo.loginWithProvider(provider);
        expect(result, isA<Success<User>>());
        expect(repo.session.user?.email, '${provider.name}@example.com');
        expect(credentials.token, 'demo-${provider.name}-access-token');
        expect(requests.length, 2);
        expect(
          requests.every(
            (request) => !request.headers.containsKey('Authorization'),
          ),
          isTrue,
        );
        expect(logs.join(), isNot(contains('code_verifier')));
        expect(logs.join(), isNot(contains('demo-code')));
        expect(logs.join(), isNot(contains('access-token')));
        final freshLocal = PersistentIdentitySession(credentials);
        addTearDown(freshLocal.dispose);
        dio.httpClientAdapter = DemoAdapter(latency: Duration.zero);
        dio.interceptors.removeWhere(
          (interceptor) => interceptor is AuthInterceptor,
        );
        dio.interceptors.insert(
          0,
          AuthInterceptor(freshLocal, baseUrl: 'https://demo.invalid'),
        );
        final freshRepo = RemoteIdentityRepository(
          ApiAuthRemoteDataSource(AuthApi(dio)),
          freshLocal,
          BrowserOAuthRemoteDataSource(AuthApi(dio), browser, config),
        );
        expect(await freshRepo.restoreSession(), isA<Success<User?>>());
        expect(freshRepo.session.user?.email, '${provider.name}@example.com');
        await freshRepo.logout();
        expect(credentials.token, isNull);
      },
    );
  }

  test('invalid callback never reaches exchange or persistence', () async {
    final repo = repository(
      overrideBrowser: CallbackOAuthBrowser(
        (authorization, redirect) async => redirect
            .replace(queryParameters: {'code': 'stolen', 'state': 'wrong'})
            .toString(),
      ),
    );
    final result = await repo.loginWithProvider(IdentityProvider.google);
    expect((result as FailureResult<User>).failure.kind, FailureKind.security);
    expect(requests, isEmpty);
    expect(credentials.token, isNull);
  });

  test(
    'browser cancellation releases the attempt so sign-in can be retried',
    () async {
      var cancelled = true;
      final repo = repository(
        overrideBrowser: CallbackOAuthBrowser((authorization, redirect) {
          if (cancelled) {
            throw const Failure(FailureKind.cancelled, 'Cancelled');
          }
          return browser.authenticate(authorization, redirect);
        }),
      );
      expect(
        ((await repo.loginWithProvider(
          IdentityProvider.google,
        )) as FailureResult<User>).failure.kind,
        FailureKind.cancelled,
      );
      expect(requests, isEmpty);
      cancelled = false;
      expect(
        await repo.loginWithProvider(IdentityProvider.google),
        isA<Success<User>>(),
      );
    },
  );

  test('logout while the browser is open prevents late credentials from being saved', () async {
    final opened = Completer<void>();
    final callback = Completer<String>();
    final repo = repository(
      overrideBrowser: CallbackOAuthBrowser((authorization, redirect) async {
        final response = await browser.authenticate(authorization, redirect);
        opened.complete();
        await callback.future;
        return response;
      }),
    );
    final pending = repo.loginWithProvider(IdentityProvider.google);
    await opened.future;
    await repo.logout();
    callback.complete('resume');
    expect(
      ((await pending) as FailureResult<User>).failure.kind,
      FailureKind.cancelled,
    );
    expect(repo.session, isA<SessionUnauthenticated>());
    expect(credentials.token, isNull);
  });

  test(
    'logout keeps provider admission occupied until the browser returns',
    () async {
      final opened = Completer<void>();
      final resume = Completer<void>();
      var calls = 0;
      final repo = repository(
        overrideBrowser: CallbackOAuthBrowser((authorization, redirect) async {
          if (++calls == 1) {
            opened.complete();
            await resume.future;
          }
          return browser.authenticate(authorization, redirect);
        }),
      );
      final login = LoginWithProvider(repo);
      final first = login(IdentityProvider.google);
      await opened.future;
      await repo.logout();
      final second = await login(IdentityProvider.github);
      expect(
        (second as FailureResult<User>).failure.kind,
        FailureKind.conflict,
      );
      expect(calls, 1);
      resume.complete();
      expect(
        ((await first) as FailureResult<User>).failure.kind,
        FailureKind.cancelled,
      );
      expect(await login(IdentityProvider.github), isA<Success<User>>());
    },
  );

  test(
    'storage errors cannot publish an authenticated OAuth session',
    () async {
      credentials.failWrites = true;
      final repo = repository();
      final result = await repo.loginWithProvider(IdentityProvider.google);
      expect((result as FailureResult<User>).failure.kind, FailureKind.storage);
      expect(repo.session.isAuthenticated, isFalse);
    },
  );

  test(
    'broker consumes codes once and validates the verifier and provider',
    () async {
      final api = AuthApi(dio);
      Future<OAuthExchangeRequest> authorize() async {
        final attempt = OAuthAttempt(redirectUri: config.redirectUri!);
        return attempt.exchangeRequest(
          Uri.parse(
            await browser.authenticate(
              attempt.authorizationUri(
                config.apiOrigin,
                IdentityProvider.google,
              ),
              config.redirectUri!,
            ),
          ),
        );
      }

      final request = await authorize();
      await api.exchangeOAuth('google', request);
      await expectLater(
        () => api.exchangeOAuth('google', request),
        throwsA(isA<DioException>()),
      );
      final wrongVerifier = await authorize();
      await expectLater(
        () => api.exchangeOAuth(
          'google',
          OAuthExchangeRequest(
            code: wrongVerifier.code,
            codeVerifier: 'wrong',
            redirectUri: wrongVerifier.redirectUri,
          ),
        ),
        throwsA(isA<DioException>()),
      );
      await expectLater(
        () => api.exchangeOAuth('google', wrongVerifier),
        throwsA(isA<DioException>()),
      );
      final wrongProvider = await authorize();
      await expectLater(
        () => api.exchangeOAuth('github', wrongProvider),
        throwsA(isA<DioException>()),
      );
    },
  );
}
