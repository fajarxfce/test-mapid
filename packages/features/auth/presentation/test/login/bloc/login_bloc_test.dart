import 'dart:async';

import 'package:auth_presentation/auth_presentation.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:core_common/core_common.dart';
import 'package:core_testing/core_testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:identity_domain/identity_domain.dart';

class MockIdentityRepository extends Mock implements IdentityRepository {}

void main() {
  late MockIdentityRepository repository;
  setUp(() {
    repository = MockIdentityRepository();
    when(() => repository.providers)
        .thenReturn(IdentityProvider.values.toSet());
  });
  LoginBloc create() => LoginBloc(
    Login(repository),
    LoginWithProvider(repository),
    GetIdentityProviders(repository),
    const AppEnvironment(label: 'test', isDemo: true),
  );
  void fill(LoginBloc bloc) {
    bloc.add(const LoginEmailChanged('demo@example.com'));
    bloc.add(const LoginPasswordChanged('Demo123!'));
  }

  test('Formz validates email and minimum password length', () {
    expect(const EmailInput.dirty('invalid').isValid, isFalse);
    expect(const EmailInput.dirty('demo@example.com').isValid, isTrue);
    expect(const PasswordInput.dirty('short').isValid, isFalse);
    expect(const PasswordInput.dirty('Demo123!').isValid, isTrue);
  });
  blocTest<LoginBloc, LoginState>(
    'invalid submit event never calls repository',
    build: create,
    act: (bloc) => bloc.add(const LoginSubmitted()),
    expect: () => [
      isA<LoginState>().having(
        (state) => state.email.displayError,
        'email error',
        isNotNull,
      ),
    ],
    verify: (_) => verifyNever(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ),
  );
  test(
    'rapid submit events send one request and ignore edits while pending',
    () async {
      final pending = Completer<Result<User>>();
      when(
        () => repository.login(email: 'demo@example.com', password: 'Demo123!'),
      ).thenAnswer((_) => pending.future);
      final bloc = create();
      addTearDown(bloc.close);
      final submitting = bloc.stream.firstWhere(
        (state) => state.status.isInProgress,
      );
      fill(bloc);
      bloc.add(const LoginSubmitted());
      bloc.add(const LoginSubmitted());
      await submitting;
      bloc.add(const LoginSubmitted());
      bloc.add(const LoginEmailChanged('changed@example.com'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.email.value, 'demo@example.com');
      final success = bloc.stream.firstWhere((state) => state.status.isSuccess);
      pending.complete(
        const Success(
          User(id: '1', email: 'demo@example.com', displayName: 'Demo'),
        ),
      );
      await success;
      verify(
        () => repository.login(email: 'demo@example.com', password: 'Demo123!'),
      ).called(1);
    },
  );
  test('failed submit can be retried with another submit event', () async {
    when(
      () => repository.login(email: 'demo@example.com', password: 'Demo123!'),
    ).thenAnswer(
      (_) async => const FailureResult(Failure(FailureKind.network, 'Offline')),
    );
    final bloc = create();
    addTearDown(bloc.close);
    final failed = bloc.stream.firstWhere((state) => state.status.isFailure);
    fill(bloc);
    bloc.add(const LoginSubmitted());
    await failed;
    expect(bloc.state.error, 'Offline');
    // Wait for the droppable handler to complete before retrying.
    await Future<void>.delayed(Duration.zero);
    when(
      () => repository.login(email: 'demo@example.com', password: 'Demo123!'),
    ).thenAnswer(
      (_) async => const Success(
        User(id: '1', email: 'demo@example.com', displayName: 'Demo'),
      ),
    );
    final success = bloc.stream.firstWhere((state) => state.status.isSuccess);
    bloc.add(const LoginSubmitted());
    await success;
    verify(
      () => repository.login(email: 'demo@example.com', password: 'Demo123!'),
    ).called(2);
  });
  test('provider login blocks other methods until it finishes', () async {
    final pending = Completer<Result<User>>();
    when(() => repository.loginWithProvider(IdentityProvider.google))
        .thenAnswer((_) => pending.future);
    final bloc = create();
    addTearDown(bloc.close);
    final submitting = bloc.stream.firstWhere(
      (state) => state.status.isInProgress,
    );
    bloc.add(const LoginProviderSubmitted(LoginProvider.google));
    await submitting;
    expect(bloc.state.activeProvider, LoginProvider.google);
    bloc.add(const LoginProviderSubmitted(LoginProvider.github));
    bloc.add(const LoginSubmitted());
    bloc.add(const LoginEmailChanged('ignored@example.com'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.email.value, isEmpty);
    verifyNever(() => repository.loginWithProvider(IdentityProvider.github));
    verifyNever(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
    final success = bloc.stream.firstWhere((state) => state.status.isSuccess);
    pending.complete(
      const Success(
        User(id: 'google', email: 'google@example.com', displayName: 'Google'),
      ),
    );
    await success;
    expect(bloc.state.activeProvider, isNull);
    verify(() => repository.loginWithProvider(IdentityProvider.google))
        .called(1);
  });

  test(
    'cancelled provider login clears busy state without an error banner',
    () async {
      when(
        () => repository.loginWithProvider(IdentityProvider.github),
      ).thenAnswer(
        (_) async =>
            const FailureResult(Failure(FailureKind.cancelled, 'Cancelled')),
      );
      final bloc = create();
      addTearDown(bloc.close);
      final finished = bloc.stream.skip(1).first;
      bloc.add(const LoginProviderSubmitted(LoginProvider.github));
      final state = await finished;
      expect(state.status, FormzSubmissionStatus.initial);
      expect(state.activeProvider, isNull);
      expect(state.error, isNull);
    },
  );

  test('a disabled method ignores synthetic events', () async {
    when(() => repository.providers).thenReturn({});
    final bloc = create();
    addTearDown(bloc.close);
    bloc.add(const LoginProviderSubmitted(LoginProvider.google));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.providers, isEmpty);
    verifyNever(() => repository.loginWithProvider(IdentityProvider.google));
  });
}
