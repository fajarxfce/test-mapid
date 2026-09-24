import 'package:core_common/core_common.dart';

/// Development-only session simulation, separate from the authentication API.
abstract interface class DemoSessionRepository {
  Future<Result<void>> expireSession();
}
