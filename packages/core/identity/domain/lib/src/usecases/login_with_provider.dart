import 'package:core_common/core_common.dart';
import 'package:identity_domain/src/entities/identity_provider.dart';
import 'package:identity_domain/src/entities/user.dart';
import 'package:identity_domain/src/repositories/identity_repository.dart';

/// Admits one provider sign-in at a time, shared across callers in the app.
final class LoginWithProvider {
  LoginWithProvider(this._repository);
  final IdentityRepository _repository;
  bool _running = false;

  Future<Result<User>> call(IdentityProvider provider) async {
    if (!_repository.providers.contains(provider)) {
      return const FailureResult(
        Failure(FailureKind.validation, 'This sign-in method is unavailable.'),
      );
    }
    if (_running) {
      return const FailureResult(
        Failure(
          FailureKind.conflict,
          'Another sign-in is already in progress.',
        ),
      );
    }
    _running = true;
    try {
      return await _repository.loginWithProvider(provider);
    } finally {
      _running = false;
    }
  }
}
