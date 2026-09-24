import 'package:identity_data/src/dto/user_dto.dart';
import 'package:identity_data/src/requests/login_request.dart';
import 'package:identity_data/src/responses/login_response.dart';

abstract interface class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<UserDto> currentUser();
}
