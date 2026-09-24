import 'package:core_common/src/failures/failure_kind.dart';

final class Failure {
  const Failure(this.kind, this.message);
  final FailureKind kind;
  final String message;
}
