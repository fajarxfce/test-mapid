import 'package:identity_domain/src/entities/session.dart';
import 'package:identity_domain/src/repositories/identity_repository.dart';

final class GetCurrentSession {
  const GetCurrentSession(this._repository);
  final IdentityRepository _repository;

  Session call() => _repository.session;
}
