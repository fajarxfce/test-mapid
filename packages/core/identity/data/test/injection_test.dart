import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:core_testing/core_testing.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:identity_data/identity_data.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart' show GetItHelper;
import 'package:test/test.dart';

void main() {
  test(
    'auth module supplies every use case using the qualified main API client',
    () async {
      final container = GetIt.asNewInstance();
      addTearDown(container.reset);
      final credentials = FakeCredentialStore();
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
        DemoAdapter(latency: Duration.zero),
        instanceName: mainApi,
      );
      // Decoys must never be selected by Retrofit or demo-session injection.
      container.registerSingleton<Dio>(Dio()..close(force: true));
      container.registerSingleton<Dio>(
        Dio()..close(force: true),
        instanceName: 'uploadApi',
      );
      await CoreNetworkPackageModule().init(GetItHelper(container));
      await IdentityDataPackageModule().init(GetItHelper(container));

      final login = container<Login>();
      final restore = container<RestoreSession>();
      final logout = container<Logout>();
      final watch = container<WatchSession>();
      final expire = container<ExpireDemoSession>();
      expect(container<Login>(), isNot(same(login)));
      expect(container<RestoreSession>(), isNot(same(restore)));
      expect(container<Logout>(), isNot(same(logout)));
      expect(container<WatchSession>(), isNot(same(watch)));
      expect(container<ExpireDemoSession>(), isNot(same(expire)));

      final signedIn = watch().skip(1).map((session) => session.user).first;
      final result = await login(
        email: 'demo@example.com',
        password: 'Demo123!',
      );
      expect(result, isA<Success<User>>());
      expect((await signedIn)?.email, 'demo@example.com');
      expect(credentials.token, 'demo-access-token');
      expect(await restore(), isA<Success<User?>>());

      expect(await expire(), isA<Success<void>>());
      final expired = await restore();
      expect(
        (expired as FailureResult<User?>).failure.kind,
        FailureKind.unauthorized,
      );
      expect(credentials.token, isNull);

      await login(email: 'demo@example.com', password: 'Demo123!');
      final signedOut = watch().skip(1).map((session) => session.user).first;
      expect(await logout(), isA<Success<void>>());
      expect(await signedOut, isNull);
      expect(credentials.token, isNull);
    },
  );
}
