import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:test/test.dart';

import 'support/controlled_identity_repository.dart';

void main() {
  late ControlledIdentityRepository repository;
  late LoginWithProvider login;
  setUp(() {
    repository = ControlledIdentityRepository();
    login = LoginWithProvider(repository);
  });

  test('unsupported providers fail without invoking the repository', () async {
    repository.providers = {IdentityProvider.google};
    final result = await login(IdentityProvider.github);
    expect(
      (result as FailureResult<User>).failure.kind,
      FailureKind.validation,
    );
    expect(repository.calls, isEmpty);
    expect(await login(IdentityProvider.google), isA<Success<User>>());
  });

  test('a concurrent method never reaches the repository or invalidates the first attempt', () async {
    final pending = Completer<Result<User>>();
    repository.onLogin = (_) => pending.future;
    final first = login(IdentityProvider.google);
    final second = await login(IdentityProvider.github);
    expect((second as FailureResult<User>).failure.kind, FailureKind.conflict);
    expect(repository.calls, [IdentityProvider.google]);
    const success = Success(
      User(id: 'google', email: 'google@example.com', displayName: 'Google'),
    );
    pending.complete(success);
    expect(await first, same(success));
    repository.onLogin = null;
    expect(await login(IdentityProvider.github), isA<Success<User>>());
    expect(repository.calls, [
      IdentityProvider.google,
      IdentityProvider.github,
    ]);
  });

  test(
    'failure and cancellation release admission for the next attempt',
    () async {
      for (final kind in [
        FailureKind.cancelled,
        FailureKind.network,
        FailureKind.unauthorized,
      ]) {
        repository.onLogin = (_) async =>
            FailureResult(Failure(kind, 'Failed'));
        expect(
          ((await login(
            IdentityProvider.google,
          )) as FailureResult<User>).failure.kind,
          kind,
        );
        repository.onLogin = null;
        expect(await login(IdentityProvider.github), isA<Success<User>>());
      }
    },
  );
}
