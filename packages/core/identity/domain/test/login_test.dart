import 'package:core_common/core_common.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:test/test.dart';

class RecordingRepository implements IdentityRepository {
  String? submittedEmail;
  String? submittedPassword;
  @override
  Set<IdentityProvider> get providers => const {};
  @override
  Future<Result<User>> loginWithProvider(IdentityProvider provider) =>
      throw UnimplementedError();

  @override
  Session get session => const SessionUnauthenticated();
  @override
  Stream<Session> get sessionChanges => const Stream.empty();
  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    submittedEmail = email;
    submittedPassword = password;
    return Success(User(id: '1', email: email, displayName: 'Demo'));
  }

  @override
  Future<Result<void>> logout() async => const Success(null);
  @override
  Future<Result<User?>> restoreSession() async => const Success(null);
}

void main() {
  test('login trims email but preserves password verbatim', () async {
    final repository = RecordingRepository();
    await Login(repository)(email: ' demo@example.com ', password: ' secret ');
    expect(repository.submittedEmail, 'demo@example.com');
    expect(repository.submittedPassword, ' secret ');
  });
}
