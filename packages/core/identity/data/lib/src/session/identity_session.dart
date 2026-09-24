import 'package:core_common/core_common.dart';
import 'package:identity_data/src/models/auth_session.dart';
import 'package:identity_domain/identity_domain.dart';

/// Data-layer owner of session state and consistent credential persistence.
/// Callers supply remote operations; cancellation and storage ordering stay here.
abstract interface class IdentitySession {
  Session get session;
  Stream<Session> get sessionChanges;
  Future<Result<User>> authenticate(Future<AuthSession> Function() request);
  Future<Result<User?>> restore(Future<User> Function() loadUser);
  Future<Result<void>> logout();
}
