import 'package:identity_domain/src/entities/session.dart';
import 'package:identity_domain/src/repositories/identity_repository.dart';

final class WatchSession {
  const WatchSession(this._repository);
  final IdentityRepository _repository;
  Stream<Session> call() => _repository.sessionChanges;
}
