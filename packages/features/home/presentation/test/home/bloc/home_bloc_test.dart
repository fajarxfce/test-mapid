import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_presentation/home_presentation.dart';
import 'package:identity_domain/identity_domain.dart';

import '../../support/fake_identity_repository.dart';

const user = User(id: '1', displayName: 'Alex', email: 'alex@example.com');
HomeBloc createBloc(FakeIdentityRepository repository, {bool demo = true}) =>
    HomeBloc(
      WatchSession(repository),
      GetCurrentSession(repository),
      RestoreSession(repository),
      Logout(repository),
      ExpireDemoSession(repository),
      AppEnvironment(label: 'test', isDemo: demo),
    );

void main() {
  test(
    'reads shared identity state without depending on another Bloc',
    () async {
      final repository = FakeIdentityRepository(
        const SessionAuthenticated(user),
      );
      final bloc = createBloc(repository);
      addTearDown(repository.close);
      addTearDown(bloc.close);
      expect(bloc.state.displayName, 'Alex');
      final changed = bloc.stream.firstWhere((state) => state.email.isEmpty);
      repository.update(const SessionUnauthenticated());
      await changed;
      expect(bloc.state.displayName, isEmpty);
    },
  );

  test(
    'session is shared while loading and feedback stay local to each Bloc',
    () async {
      final repository = FakeIdentityRepository(
        const SessionAuthenticated(user),
      );
      final pending = Completer<Result<User?>>();
      repository.pendingRestore = pending.future;
      final first = createBloc(repository);
      final second = createBloc(repository);
      addTearDown(repository.close);
      addTearDown(first.close);
      addTearDown(second.close);
      final started = first.stream.firstWhere((state) => state.busy);
      first.add(const HomeSessionCheckRequested());
      await started;
      expect(second.state.busy, isFalse);
      expect(second.state.message, isNull);
      final finished = first.stream.firstWhere((state) => !state.busy);
      pending.complete(const Success(user));
      await finished;
      expect(first.state.message, 'Your session is up to date.');
      expect(second.state.message, isNull);
    },
  );

  test(
    'check and logout failures finish local loading and expose feedback',
    () async {
      final repository = FakeIdentityRepository(
        const SessionAuthenticated(user),
      );
      const failure = Failure(FailureKind.storage, 'Storage unavailable');
      repository.pendingRestore = Future.value(const FailureResult(failure));
      repository.logoutResult = const FailureResult(failure);
      final bloc = createBloc(repository);
      addTearDown(repository.close);
      addTearDown(bloc.close);
      var finished = bloc.stream.firstWhere(
        (state) => !state.busy && state.message != null,
      );
      bloc.add(const HomeSessionCheckRequested());
      await finished;
      expect(bloc.state.message, failure.message);
      finished = bloc.stream.firstWhere(
        (state) => !state.busy && state.message != null,
      );
      bloc.add(const HomeLogoutRequested());
      await finished;
      expect(repository.actions, ['check', 'logout']);
      await pumpEventQueue();
      expect(bloc.state.email, isEmpty);
    },
  );

  test(
    'expiry is available only in demo mode and revalidates the session',
    () async {
      final repository = FakeIdentityRepository();
      final live = createBloc(repository, demo: false);
      final demo = createBloc(repository);
      addTearDown(repository.close);
      addTearDown(live.close);
      addTearDown(demo.close);
      live.add(const HomeSessionExpiryRequested());
      await pumpEventQueue();
      expect(repository.actions, isEmpty);
      demo.add(const HomeSessionExpiryRequested());
      await pumpEventQueue();
      expect(repository.actions, ['expire', 'check']);
      expect(demo.state.busy, isFalse);
    },
  );

  test('closing a route Bloc releases its identity subscription', () async {
    final repository = FakeIdentityRepository();
    addTearDown(repository.close);
    final bloc = createBloc(repository);
    expect(repository.hasListener, isTrue);
    await bloc.close();
    expect(repository.hasListener, isFalse);
    repository.update(const SessionAuthenticated(user));
    expect(bloc.state.displayName, isEmpty);
  });
}
