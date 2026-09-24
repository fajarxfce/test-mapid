import 'package:core_common/core_common.dart';
import 'package:identity_domain/src/entities/identity_provider.dart';
import 'package:identity_domain/src/entities/session.dart';
import 'package:identity_domain/src/entities/user.dart';

abstract interface class IdentityRepository {
  Set<IdentityProvider> get providers;
  Session get session;

  /// Emits the current snapshot on subscription, then every session change.
  Stream<Session> get sessionChanges;
  Future<Result<User>> login({required String email, required String password});
  Future<Result<User>> loginWithProvider(IdentityProvider provider);
  Future<Result<User?>> restoreSession();
  Future<Result<void>> logout();
}
