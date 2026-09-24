import 'package:identity_data/src/datasources/remote/auth_remote_data_source.dart';
import 'package:identity_data/src/dto/user_dto.dart';
import 'package:identity_data/src/requests/login_request.dart';
import 'package:identity_data/src/responses/login_response.dart';
import 'package:identity_data/src/services/auth_api.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRemoteDataSource)
final class ApiAuthRemoteDataSource implements AuthRemoteDataSource {
  ApiAuthRemoteDataSource(this._api);

  final AuthApi _api;

  @override
  Future<LoginResponse> login(LoginRequest request) => _api.login(request);

  @override
  Future<UserDto> currentUser() => _api.currentUser();
}
