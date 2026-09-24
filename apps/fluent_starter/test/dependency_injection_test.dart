import 'package:auth_presentation/auth_presentation.dart';
import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:core_testing/core_testing.dart';
import 'package:dio/dio.dart';
import 'package:fluent_starter/config/app_config.dart';
import 'package:fluent_starter/di/injection.dart';
import 'package:fluent_starter/routing/app_router.dart';
import 'package:fluent_starter/routing/guards/session_guard.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity_data/identity_data.dart';
import 'package:identity_domain/identity_domain.dart';

void main() {
  test(
    'generated modules resolve the complete login graph and lifecycle',
    () async {
      final credentials = FakeCredentialStore();
      final container = await configureDependencies(
        AppConfig.parse(flavor: 'dev', backend: 'demo'),
        credentials: credentials,
        preferences: FakePreferenceStore(),
      );
      addTearDown(container.reset);
      expect(
        container<AuthRemoteDataSource>(),
        same(container<AuthRemoteDataSource>()),
      );
      expect(
        container<IdentitySession>(),
        same(container<HttpAuthentication>(instanceName: mainApi)),
      );
      final repository = container<IdentityRepository>();
      expect(repository, isA<RemoteIdentityRepository>());
      expect(container<IdentityRepository>(), same(repository));
      expect(container<SessionGuard>(), isA<SessionGuard>());
      expect(container<GetCurrentSession>()(), isA<SessionUnauthenticated>());
      expect(
        container<HttpClientAdapter>(instanceName: mainApi),
        isA<DemoAdapter>(),
      );

      final bloc = container<LoginBloc>();
      final secondBloc = container<LoginBloc>();
      addTearDown(bloc.close);
      addTearDown(secondBloc.close);
      expect(secondBloc, isNot(same(bloc)));
      expect(container<Login>(), isNot(same(container<Login>())));
      final router = container<AppRouter>();
      final secondRouter = container<AppRouter>();
      expect(secondRouter, same(router));

      final signedIn = repository.sessionChanges
          .skip(1)
          .map((session) => session.user)
          .firstWhere((user) => user != null);
      bloc.add(const LoginEmailChanged('demo@example.com'));
      bloc.add(const LoginPasswordChanged('Demo123!'));
      bloc.add(const LoginSubmitted());
      expect((await signedIn)?.email, 'demo@example.com');
      expect(credentials.token, 'demo-access-token');
      expect(await container<RestoreSession>()(), isA<Success<User?>>());
      expect(await container<Logout>()(), isA<Success<void>>());
      expect(repository.session.user, isNull);
      expect(credentials.token, isNull);
      await bloc.close();
      await secondBloc.close();

      final sessionStreamClosed = expectLater(
        repository.sessionChanges.skip(1).map((session) => session.user),
        emitsDone,
      );
      await container.reset();
      await sessionStreamClosed;
    },
  );

  test('provider use case is shared across callers and rejects concurrent authorization', () async {
    final container = await configureDependencies(
      AppConfig.parse(flavor: 'dev', backend: 'demo'),
      credentials: FakeCredentialStore(),
      preferences: FakePreferenceStore(),
    );
    addTearDown(container.reset);
    final first = container<LoginWithProvider>();
    final second = container<LoginWithProvider>();
    expect(second, same(first));
    final pending = first(IdentityProvider.google);
    final rejected = await second(IdentityProvider.github);
    expect(
      (rejected as FailureResult<User>).failure.kind,
      FailureKind.conflict,
    );
    expect(await pending, isA<Success<User>>());
    expect(container<GetCurrentSession>()().user?.email, 'google@example.com');
  });

  test(
    'real backend resolves the platform HTTP adapter without demo fallback',
    () async {
      final container = await configureDependencies(
        AppConfig.parse(
          flavor: 'staging',
          backend: 'api',
          baseUrl: 'https://api.example.com',
        ),
        credentials: FakeCredentialStore(),
        preferences: FakePreferenceStore(),
      );
      addTearDown(container.reset);
      final dio = container<Dio>(instanceName: mainApi);
      expect(dio.httpClientAdapter, isNot(isA<DemoAdapter>()));
      expect(dio.options.baseUrl, 'https://api.example.com');
    },
  );
}
