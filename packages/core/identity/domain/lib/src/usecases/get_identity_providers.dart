import 'package:identity_domain/src/entities/identity_provider.dart';
import 'package:identity_domain/src/repositories/identity_repository.dart';

final class GetIdentityProviders {
  const GetIdentityProviders(this._repository);
  final IdentityRepository _repository;

  Set<IdentityProvider> call() => _repository.providers;
}
