import 'package:core_common/core_common.dart';
import 'package:core_network/src/authentication/access_credential.dart';

/// HTTP's dependency on the owner of the authenticated session.
/// Implementations must not depend on the Dio client using this contract.
abstract interface class HttpAuthentication {
  Future<AccessCredential?> readCredentials();

  /// Expires only the session used by the rejected request; null means missing
  /// credentials. A response from an older session must leave a newer one intact.
  Future<Result<void>> rejectCredentials(AccessCredential? credential);
}
