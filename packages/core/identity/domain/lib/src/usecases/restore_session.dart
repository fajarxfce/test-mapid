import 'package:core_common/core_common.dart';
import 'package:identity_domain/src/entities/user.dart';
import 'package:identity_domain/src/repositories/identity_repository.dart';

final class RestoreSession {
  const RestoreSession(this._repository);
  final IdentityRepository _repository;
  Future<Result<User?>> call() => _repository.restoreSession();
}
