import 'package:core_common/core_common.dart';
import 'package:identity_domain/identity_domain.dart';

final class ControlledIdentityRepository implements IdentityRepository {
  @override
  Set<IdentityProvider> providers = IdentityProvider.values.toSet();
  final calls = <IdentityProvider>[];
  Future<Result<User>> Function(IdentityProvider)? onLogin;

  @override
  Future<Result<User>> loginWithProvider(IdentityProvider provider) {
    calls.add(provider);
    return onLogin?.call(provider) ??
        Future.value(
          const Success(
            User(
              id: 'user',
              email: 'person@example.com',
              displayName: 'Person',
            ),
          ),
        );
  }

  @override
  Session get session => const SessionUnauthenticated();
  @override
  Stream<Session> get sessionChanges => const Stream.empty();
  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) => throw UnimplementedError();
  @override
  Future<Result<void>> logout() async => const Success(null);
  @override
  Future<Result<User?>> restoreSession() async => const Success(null);
}
