import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart' show GetItHelper;
import 'package:test/test.dart';

void main() {
  test(
    'generated network provider uses the configured named client and closes it',
    () async {
      final container = GetIt.asNewInstance();
      final options = BaseOptions(
        baseUrl: 'https://geoserver.mapid.io',
        receiveTimeout: const Duration(seconds: 20),
      );
      final logging = SafeLoggingInterceptor(null);
      container.registerSingleton(options, instanceName: mapidApi);
      container.registerSingleton(logging, instanceName: mapidApi);
      await CoreNetworkPackageModule().init(GetItHelper(container));
      final dio = container<Dio>(instanceName: mapidApi);
      expect(dio.options, same(options));
      expect(container<Dio>(instanceName: mapidApi), same(dio));
      expect(container.isRegistered<Dio>(), isFalse);
      expect(dio.interceptors, contains(logging));
      await container.reset();
      await expectLater(
        dio.get<Object>('/unused'),
        throwsA(isA<DioException>()),
      );
    },
  );
}
