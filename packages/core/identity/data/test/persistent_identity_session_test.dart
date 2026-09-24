import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_testing/core_testing.dart';
import 'package:identity_data/identity_data.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:test/test.dart';

class _MockCredentials extends Mock implements CredentialStore {}

const _first = AuthSession(
  accessToken: 'first-token',
  user: User(id: 'first', email: 'first@example.com', displayName: 'First'),
);
const _second = AuthSession(
  accessToken: 'second-token',
  user: User(id: 'second', email: 'second@example.com', displayName: 'Second'),
);

void main() {
  late _MockCredentials credentials;
  late PersistentIdentitySession local;
  late Completer<void> writing;
  late Completer<void> releaseWrite;
  late List<String> writes;
  String? token;

  setUp(() {
    credentials = _MockCredentials();
    local = PersistentIdentitySession(credentials);
    writing = Completer<void>();
    releaseWrite = Completer<void>();
    writes = [];
    token = null;
    when(credentials.read).thenAnswer((_) async => token);
    when(credentials.clear).thenAnswer((_) async => token = null);
    when(() => credentials.write(any())).thenAnswer((invocation) async {
      final value = invocation.positionalArguments.first as String;
      writes.add(value);
      if (value == _first.accessToken) {
        writing.complete();
        await releaseWrite.future;
      }
      token = value;
    });
  });
  tearDown(() async {
    if (!releaseWrite.isCompleted) releaseWrite.complete();
    await local.dispose();
  });

  test('stale write rollback cannot erase a newer committed session', () async {
    final published = <User?>[];
    final subscription = local.sessionChanges
        .skip(1)
        .map((session) => session.user)
        .listen(published.add);
    addTearDown(subscription.cancel);
    final first = local.authenticate(() async => _first);
    await writing.future;
    final second = local.authenticate(() async => _second);
    await Future<void>.delayed(Duration.zero);
    expect(writes, ['first-token']);
    expect(local.session.user, isNull);
    releaseWrite.complete();
    expect(
      (await first as FailureResult<User>).failure.kind,
      FailureKind.cancelled,
    );
    expect((await second as Success<User>).value, same(_second.user));
    await Future<void>.delayed(Duration.zero);
    expect(published, [_second.user]);
    expect(token, 'second-token');
    expect(local.session.user, same(_second.user));
  });

  test(
    'queued logout clears the old token before a newer login writes',
    () async {
      final first = local.authenticate(() async => _first);
      await writing.future;
      final logout = local.logout();
      final second = local.authenticate(() async => _second);
      releaseWrite.complete();
      expect(await first, isA<FailureResult<User>>());
      expect(await logout, isA<Success<void>>());
      expect(await second, isA<Success<User>>());
      expect(token, 'second-token');
      expect(local.session.user, same(_second.user));
    },
  );

  test('a storage failure does not block subsequent session commits', () async {
    when(() => credentials.write(_first.accessToken))
        .thenThrow(StateError('locked'));
    final first = await local.authenticate(() async => _first);
    expect((first as FailureResult<User>).failure.kind, FailureKind.storage);
    expect(local.session.user, isNull);
    final second = await local.authenticate(() async => _second);
    expect(second, isA<Success<User>>());
    expect(token, 'second-token');
  });

  test(
    'disposal waits for pending rollback and closes session notifications',
    () async {
      final first = local.authenticate(() async => _first);
      await writing.future;
      final notifications = expectLater(
        local.sessionChanges.skip(1).map((session) => session.user),
        emitsDone,
      );
      var disposed = false;
      final closing = local.dispose().then((_) => disposed = true);
      await Future<void>.delayed(Duration.zero);
      expect(disposed, isFalse);
      releaseWrite.complete();
      expect(
        (await first as FailureResult<User>).failure.kind,
        FailureKind.cancelled,
      );
      await closing;
      await notifications;
      expect(token, isNull);
      expect(local.session.user, isNull);
    },
  );
  test('a successful new login supersedes a pending restore', () async {
    token = 'old-token';
    final started = Completer<void>();
    final response = Completer<User>();
    final restore = local.restore(() {
      started.complete();
      return response.future;
    });
    await started.future;
    await local.authenticate(() async => _second);
    expect(
      ((await restore) as FailureResult<User?>).failure.kind,
      FailureKind.cancelled,
    );
    response.complete(_first.user);
    await Future<void>.delayed(Duration.zero);
    expect(local.session.user, same(_second.user));
    expect(token, _second.accessToken);
  });

  test(
    'logout remains effective in memory when credential deletion fails',
    () async {
      await local.authenticate(() async => _second);
      when(credentials.clear).thenThrow(StateError('locked'));
      final result = await local.logout();
      expect((result as FailureResult<void>).failure.kind, FailureKind.storage);
      expect(local.session, isA<SessionUnauthenticated>());
      expect(await local.readCredentials(), isNull);
      expect(
        await local.restore(() => throw StateError('must not call server')),
        isA<Success<User?>>(),
      );
      expect(local.session, isA<SessionUnauthenticated>());
    },
  );

  test(
    'missing credentials from an older request cannot expire a new session',
    () async {
      expect(await local.readCredentials(), isNull);
      await local.authenticate(() async => _second);
      await local.rejectCredentials(null);
      expect(local.session.user, same(_second.user));
      expect(token, _second.accessToken);
    },
  );

  test('reading credentials does not publish a session transition', () async {
    final states = <Session>[];
    final subscription = local.sessionChanges.listen(states.add);
    addTearDown(subscription.cancel);
    token = _second.accessToken;
    expect((await local.readCredentials())?.token, token);
    token = null;
    expect(await local.readCredentials(), isNull);
    await Future<void>.delayed(Duration.zero);
    expect(states, [isA<SessionUninitialized>()]);
  });
}
