import 'package:identity_data/src/mappers/user_mapper.dart';
import 'package:identity_data/src/models/auth_session.dart';
import 'package:identity_data/src/responses/login_response.dart';

extension AuthSessionMapper on LoginResponse {
  AuthSession toSession() {
    if (accessToken.trim().isEmpty) {
      throw const FormatException('The service returned an empty session.');
    }
    return AuthSession(accessToken: accessToken, user: user.toEntity());
  }
}
