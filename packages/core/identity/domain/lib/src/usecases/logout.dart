import 'package:core_common/core_common.dart';
import 'package:identity_domain/src/repositories/identity_repository.dart';

final class Logout {
  const Logout(this._repository);
  final IdentityRepository _repository;
  Future<Result<void>> call() => _repository.logout();
}
