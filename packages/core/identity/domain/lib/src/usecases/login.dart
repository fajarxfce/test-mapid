import 'package:core_common/core_common.dart';
import 'package:identity_domain/src/entities/user.dart';
import 'package:identity_domain/src/repositories/identity_repository.dart';

final class Login {
  const Login(this._repository);
  final IdentityRepository _repository;
  Future<Result<User>> call({
    required String email,
    required String password,
  }) => _repository.login(email: email.trim(), password: password);
}
