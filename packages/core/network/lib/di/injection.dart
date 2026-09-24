import 'package:core_network/di/network_clients.dart';
import 'package:core_network/src/authentication/http_authentication.dart';
import 'package:core_network/src/interceptors/auth_interceptor.dart';
import 'package:core_network/src/interceptors/safe_logging_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [
    BaseOptions,
    HttpAuthentication,
    HttpClientAdapter,
    SafeLoggingInterceptor,
  ],
  throwOnMissingDependencies: true,
)
void configureNetworkPackage() {}

@module
abstract class NetworkModule {
  @Named(mainApi)
  @lazySingleton
  AuthInterceptor mainApiAuthentication(
    @Named(mainApi) HttpAuthentication credentials,
    @Named(mainApi) BaseOptions options,
  ) => AuthInterceptor(credentials, baseUrl: options.baseUrl);

  @Named(mainApi)
  @LazySingleton(dispose: disposeDio)
  Dio mainApiDio(
    @Named(mainApi) BaseOptions options,
    @Named(mainApi) HttpClientAdapter adapter,
    @Named(mainApi) AuthInterceptor credentials,
    @Named(mainApi) SafeLoggingInterceptor logging,
  ) => Dio(options)
    ..httpClientAdapter = adapter
    ..interceptors.addAll([credentials, logging]);
}

void disposeDio(Dio dio) => dio.close(force: true);
