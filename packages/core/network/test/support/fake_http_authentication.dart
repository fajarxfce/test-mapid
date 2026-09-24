import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';

final class FakeHttpAuthentication implements HttpAuthentication {
  FakeHttpAuthentication([String? token])
    : credential = token == null ? null : AccessCredential(token);

  AccessCredential? credential;
  final rejected = <AccessCredential?>[];
  Object? readError;
  Result<void> rejectionResult = const Success(null);

  @override
  Future<AccessCredential?> readCredentials() async {
    if (readError case final error?) throw error;
    return credential;
  }

  @override
  Future<Result<void>> rejectCredentials(AccessCredential? credential) async {
    rejected.add(credential);
    if (identical(this.credential, credential)) this.credential = null;
    return rejectionResult;
  }
}
