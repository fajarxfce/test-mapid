import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:core_testing/core_testing.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:identity_data/identity_data.dart';
import 'package:identity_data/src/datasources/demo/demo_oauth_browser.dart';
import 'package:identity_data/src/datasources/remote/api_auth_remote_data_source.dart';
import 'package:identity_data/src/datasources/remote/browser_oauth_remote_data_source.dart';
import 'package:identity_data/src/services/auth_api.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart' show GetItHelper;
import 'package:test/test.dart';

void main() {
  late FakeCredentialStore store;
  late DemoAdapter adapter;
  late Dio dio;
  late RemoteIdentityRepository repository;
  late PersistentIdentitySession local;
  final containers = <GetIt>[];
  Future<Dio> createClient({void Function(String)? log}) async {
    final container = GetIt.asNewInstance();
    containers.add(container);
    container.registerSingleton<HttpAuthentication>(
      local,
      instanceName: mainApi,
    );
    container.registerSingleton(
      BaseOptions(baseUrl: 'https://demo.invalid'),
      instanceName: mainApi,
    );
    container.registerSingleton(
      SafeLoggingInterceptor(log),
      instanceName: mainApi,
    );
    container.registerSingleton<CredentialStore>(store);
    container.registerSingleton<HttpClientAdapter>(
      adapter,
      instanceName: mainApi,
    );
    await CoreNetworkPackageModule().init(GetItHelper(container));
    return container<Dio>(instanceName: mainApi);
  }

  setUp(() async {
    store = FakeCredentialStore();
    adapter = DemoAdapter(latency: Duration.zero);
    local = PersistentIdentitySession(store);
    dio = await createClient();
    final api = AuthApi(dio);
    repository = RemoteIdentityRepository(
      ApiAuthRemoteDataSource(api),
      local,
      BrowserOAuthRemoteDataSource(
        api,
        DemoOAuthBrowser(dio),
        OAuthConfiguration(apiOrigin: Uri.parse('https://demo.invalid')),
      ),
    );
  });
  tearDown(() async {
    await local.dispose();
    for (final container in containers) {
      await container.reset();
    }
    containers.clear();
  });
  Future<Result<User>> login({
    String email = 'demo@example.com',
    String password = 'Demo123!',
  }) => repository.login(email: email, password: password);
  test(
    'Retrofit login maps JSON, persists token and restores session',
    () async {
      final result = await login();
      expect(result, isA<Success<User>>());
      expect((result as Success<User>).value.displayName, 'Alex Morgan');
      expect(store.token, 'demo-access-token');
      expect(await repository.restoreSession(), isA<Success<User?>>());
      expect(await repository.logout(), isA<Success<void>>());
      expect(store.token, isNull);
      expect(repository.session.user, isNull);
    },
  );
  test('invalid credentials do not create a session', () async {
    final result = await login(password: 'incorrect');
    expect(
      (result as FailureResult<User>).failure.kind,
      FailureKind.unauthorized,
    );
    expect(store.token, isNull);
    expect(repository.session.user, isNull);
  });
  test('expired token clears persisted session and emits logout', () async {
    await login();
    adapter.expireSession = true;
    final changed = repository.sessionChanges
        .skip(1)
        .map((session) => session.user)
        .first;
    final result = await repository.restoreSession();
    expect(
      (result as FailureResult<User?>).failure.kind,
      FailureKind.unauthorized,
    );
    expect(await changed, isNull);
    expect(store.token, isNull);
  });
  test('maps timeout and server errors', () async {
    expect(
      ((await login(
        email: 'timeout@example.com',
      )) as FailureResult<User>).failure.kind,
      FailureKind.timeout,
    );
    expect(
      ((await login(
        email: 'server@example.com',
      )) as FailureResult<User>).failure.kind,
      FailureKind.server,
    );
  });
  test('storage failure prevents authenticated state', () async {
    store.failWrites = true;
    final result = await login();
    expect((result as FailureResult<User>).failure.kind, FailureKind.storage);
    expect(repository.session.user, isNull);
  });
  test('late login response cannot undo logout', () async {
    dio.httpClientAdapter = DemoAdapter(
      latency: const Duration(milliseconds: 30),
    );
    final pending = login();
    await repository.logout();
    expect(await pending, isA<FailureResult<User>>());
    expect(repository.session.user, isNull);
    expect(store.token, isNull);
  });
  test('checked JSON rejects a malformed user', () {
    expect(() => UserDto.fromJson({'id': 42}), throwsA(isA<Object>()));
  });
  test('logs never contain passwords or tokens', () async {
    final logs = <String>[];
    dio.close();
    dio = await createClient(log: logs.add);
    final api = AuthApi(dio);
    await api.login(
      const LoginRequest(email: 'demo@example.com', password: 'Demo123!'),
    );
    store.token = 'demo-access-token';
    await api.currentUser();
    expect(logs.join(), isNot(contains('Demo123!')));
    expect(logs.join(), isNot(contains('demo-access-token')));
    expect(logs.join(), isNot(contains('demo@example.com')));
  });
}
