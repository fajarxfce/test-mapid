import 'package:core_common/core_common.dart';
import 'package:identity_data/src/datasources/remote/auth_remote_data_source.dart';
import 'package:identity_data/src/datasources/remote/oauth_remote_data_source.dart';
import 'package:identity_data/src/mappers/auth_session_mapper.dart';
import 'package:identity_data/src/mappers/user_mapper.dart';
import 'package:identity_data/src/requests/login_request.dart';
import 'package:identity_data/src/session/identity_session.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IdentityRepository)
final class RemoteIdentityRepository implements IdentityRepository {
  RemoteIdentityRepository(this._remote, this._session, this._oauth);

  final AuthRemoteDataSource _remote;
  final IdentitySession _session;
  final OAuthRemoteDataSource _oauth;

  @override
  Set<IdentityProvider> get providers => _oauth.providers;

  @override
  Future<Result<User>> loginWithProvider(IdentityProvider provider) {
    return _session.authenticate(
      () async => (await _oauth.login(provider)).toSession(),
    );
  }

  @override
  Session get session => _session.session;

  @override
  Stream<Session> get sessionChanges => _session.sessionChanges;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) {
    final request = LoginRequest(email: email, password: password);
    return _session.authenticate(
      () async => (await _remote.login(request)).toSession(),
    );
  }

  @override
  Future<Result<User?>> restoreSession() =>
      _session.restore(() async => (await _remote.currentUser()).toEntity());

  @override
  Future<Result<void>> logout() => _session.logout();
}
