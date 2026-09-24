import 'package:core_location_domain/core_location_domain.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:fluent_starter/config/app_config.dart';
import 'package:fluent_starter/config/app_flavor.dart';
import 'package:fluent_starter/di/injection.dart';
import 'package:fluent_starter/routing/app_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/map_presentation.dart';

void main() {
  test(
    'generated package modules compose the map and its qualified HTTP client',
    () async {
      final container = await configureDependencies(
        const AppConfig(
          flavor: AppFlavor.dev,
          apiKey: 'test-key',
          layerId: 'layer',
          projectId: 'project',
        ),
      );
      addTearDown(container.reset);
      expect(container<LoadMapLayer>(), isA<LoadMapLayer>());
      expect(container<GetCurrentLocation>(), isA<GetCurrentLocation>());
      expect(container<WatchLocation>(), isA<WatchLocation>());
      expect(container<OpenLocationSettings>(), isA<OpenLocationSettings>());
      final dio = container<Dio>(instanceName: mapidApi);
      expect(dio.options.baseUrl, 'https://geoserver.mapid.io');
      expect(dio.options.receiveTimeout, const Duration(seconds: 20));
      final router = container<AppRouter>();
      expect(router.routes.first.page.name, MapRoute.name);
      expect(router.routes.first.path, '/');
      expect(router.routes.first.guards, isEmpty);
    },
  );
}
