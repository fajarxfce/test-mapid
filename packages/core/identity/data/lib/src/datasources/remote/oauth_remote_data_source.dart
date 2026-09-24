import 'package:identity_data/src/responses/login_response.dart';
import 'package:identity_domain/identity_domain.dart';

/// Browser authorization and application-code exchange, without session mutation.
abstract interface class OAuthRemoteDataSource {
  Set<IdentityProvider> get providers;
  Future<LoginResponse> login(IdentityProvider provider);
}
