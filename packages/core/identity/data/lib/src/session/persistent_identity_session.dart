import 'dart:async';

import 'package:async/async.dart' show CancelableOperation;
import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:identity_data/src/models/auth_session.dart';
import 'package:identity_data/src/session/identity_session.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

/// Owns session lifecycle, not provider policy or HTTP error classification.
/// The lock protects credential commits; cancellation prevents obsolete remote
/// results from committing. Neither mechanism is exposed to the repository.
@lazySingleton
final class PersistentIdentitySession
    implements IdentitySession, HttpAuthentication {
  PersistentIdentitySession(this._credentials);

  final CredentialStore _credentials;
  final _storage = Lock();
  final _sessions = BehaviorSubject<Session>.seeded(
    const SessionUninitialized(),
  );
  CancelableOperation<Result<User>>? _authentication;
  CancelableOperation<Result<User?>>? _restoration;
  AccessCredential? _credential;
  bool _disposed = false;

  static const _cancelled = FailureResult<Never>(
    Failure(
      FailureKind.cancelled,
      'The session changed. Please sign in again.',
    ),
  );

  @override
  Session get session => _sessions.value;
  @override
  Stream<Session> get sessionChanges =>
      _disposed ? const Stream.empty() : _sessions.stream;

  @override
  Future<Result<User>> authenticate(
    Future<AuthSession> Function() request,
  ) async {
    if (_disposed) return _cancelled;
    unawaited(_authentication?.cancel());
    unawaited(_restoration?.cancel());
    late final CancelableOperation<Result<User>> authentication;
    final transaction = networkBoundResource<AuthSession, User>(
      fetch: request,
      save: (authenticated) => _storage.synchronized(() async {
        if (authentication.isCanceled) return _cancelled;
        final saved = await safeStorageCall(
          () => _credentials.write(authenticated.accessToken),
        );
        return saved.flatMap((_) async {
          if (authentication.isCanceled) {
            // Still under the same lock: cleanup cannot erase a newer commit.
            final cleared = await safeStorageCall(_credentials.clear);
            return cleared.flatMap((_) => _cancelled);
          }
          _credential = AccessCredential(authenticated.accessToken);
          _sessions.add(SessionAuthenticated(authenticated.user));
          return Success(authenticated.user);
        });
      }),
    );
    authentication = CancelableOperation.fromFuture(
      transaction,
      onCancel: () async {
        // The external browser/request still owns resources until it returns.
        // Keep the sign-in use case occupied while preventing its result from committing.
        await transaction;
      },
    );
    _authentication = authentication;
    final result = await authentication.valueOrCancellation(_cancelled);
    if (identical(_authentication, authentication)) _authentication = null;
    return result!;
  }

  @override
  Future<Result<User?>> restore(Future<User> Function() loadUser) async {
    if (_disposed) return _cancelled;
    final authentication = _authentication;
    if (authentication != null) {
      return (await authentication.valueOrCancellation(_cancelled))!;
    }
    final pending = _restoration;
    if (pending != null) {
      return (await pending.valueOrCancellation(_cancelled))!;
    }
    late final CancelableOperation<Result<User?>> restoration;
    restoration =
        CancelableOperation.fromFuture(safeStorageCall(readCredentials))
            .then<Result<User?>>(
              (stored) => stored.flatMap((credential) async {
                if (restoration.isCanceled) return _cancelled;
                if (credential == null) {
                  _sessions.add(const SessionUnauthenticated());
                  return const Success(null);
                }
                return networkBoundResource<User, User?>(
                  fetch: loadUser,
                  save: (user) => _storage.synchronized(() {
                    if (restoration.isCanceled ||
                        !identical(_credential, credential)) {
                      return _cancelled;
                    }
                    _sessions.add(SessionAuthenticated(user));
                    return Success(user);
                  }),
                );
              }),
            );
    _restoration = restoration;
    final result = await restoration.valueOrCancellation(_cancelled);
    if (identical(_restoration, restoration)) _restoration = null;
    return result!;
  }

  @override
  Future<Result<void>> logout() {
    if (_disposed) return Future.value(_cancelled);
    unawaited(_authentication?.cancel());
    unawaited(_restoration?.cancel());
    _credential = null;
    _sessions.add(const SessionUnauthenticated());
    return _storage.synchronized(() => safeStorageCall(_credentials.clear));
  }

  @override
  Future<AccessCredential?> readCredentials() =>
      _storage.synchronized(() async {
        // A failed disk cleanup must not let a signed-out app reuse that credential.
        if (_disposed || session is SessionUnauthenticated) return null;
        final token = await _credentials.read();
        if (token == null || token.trim().isEmpty) {
          _credential = null;
        } else if (_credential?.token != token) {
          _credential = AccessCredential(token);
        }
        return _credential;
      });

  @override
  Future<Result<void>> rejectCredentials(AccessCredential? credential) =>
      _storage.synchronized(() {
        if (_disposed) return _cancelled;
        if (!identical(_credential, credential)) return const Success(null);
        _credential = null;
        _sessions.add(const SessionUnauthenticated());
        if (credential == null) return const Success(null);
        return safeStorageCall(_credentials.clear);
      });

  @disposeMethod
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    unawaited(_authentication?.cancel());
    unawaited(_restoration?.cancel());
    await _storage.synchronized(_sessions.close);
  }
}
