import 'package:core_common/core_common.dart';
import 'package:identity_domain/src/repositories/demo_session_repository.dart';

final class ExpireDemoSession {
  const ExpireDemoSession(this._repository);
  final DemoSessionRepository _repository;
  Future<Result<void>> call() => _repository.expireSession();
}
