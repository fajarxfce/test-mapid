import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:identity_data/src/dto/user_dto.dart';
import 'package:identity_data/src/requests/login_request.dart';
import 'package:identity_data/src/requests/oauth_exchange_request.dart';
import 'package:identity_data/src/responses/login_response.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api.g.dart';

@RestApi()
@lazySingleton
abstract class AuthApi {
  @factoryMethod
  factory AuthApi(@Named(mainApi) Dio dio, {@ignoreParam String? baseUrl}) =
      _AuthApi;

  @POST('/auth/login')
  @Extra({'authenticated': false})
  Future<LoginResponse> login(
    @Body() LoginRequest request, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET('/auth/me')
  Future<UserDto> currentUser({@CancelRequest() CancelToken? cancelToken});

  @POST('/auth/oauth/{provider}/exchange')
  @Extra({'authenticated': false})
  Future<LoginResponse> exchangeOAuth(
    @Path('provider') String provider,
    @Body() OAuthExchangeRequest request,
  );
}
