import 'package:core_network/di/network_clients.dart';
import 'package:core_network/src/interceptors/safe_logging_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [BaseOptions, SafeLoggingInterceptor],
  throwOnMissingDependencies: true,
)
void configureNetworkPackage() {}

@module
abstract class NetworkModule {
  @Named(mapidApi)
  @LazySingleton(dispose: disposeDio)
  Dio mapidDio(
    @Named(mapidApi) BaseOptions options,
    @Named(mapidApi) SafeLoggingInterceptor logging,
  ) => Dio(options)..interceptors.add(logging);
}

void disposeDio(Dio dio) => dio.close(force: true);
