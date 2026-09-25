import 'dart:async';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/di/injection.module.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/rendering/map_renderer.dart';
import 'package:map_presentation/src/map/rendering/maplibre_renderer.dart';
import 'package:map_presentation/src/map/widgets/map_canvas.dart';
import 'package:map_presentation/src/navigation/map_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart' hide Success;
import 'package:mocktail/mocktail.dart';

import 'support/fake_repositories.dart';
import 'support/map_fixtures.dart';
import 'support/map_platform_view.dart';
import 'support/native_map_harness.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const CircleLayerProperties());
    registerFallbackValue(const SymbolLayerProperties());
    registerFallbackValue(CameraUpdate.zoomBy(1));
    registerFallbackValue(Rect.zero);
    registerFallbackValue(Uint8List(0));
  });

  testWidgets(
    'generated route DI shares one adapter and releases it when the route closes',
    (tester) async {
      final container = GetIt.asNewInstance();
      final fixes = StreamController<Result<LocationFix>>();
      final locations = FakeLocationRepository()..updates = () => fixes.stream;
      addTearDown(fixes.close);
      container.registerSingleton<GetIt>(container);
      container.registerFactory(() => LoadMapLayer(FakeMapRepository()));
      container.registerFactory(() => WatchLocation(locations));
      container.registerFactory(() => OpenLocationSettings(locations));
      await MapPresentationPackageModule().init(GetItHelper(container));
      addTearDown(container.reset);
      final previousPlatform = MapLibrePlatform.createInstance;
      MapLibrePlatform.createInstance = TestMapPlatformView.new;
      addTearDown(() => MapLibrePlatform.createInstance = previousPlatform);
      final router = RootStackRouter.build(
        routes: container<MapRouter>().routes,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(FluentApp.router(routerConfig: router.config()));
      await tester.pump();
      await tester.pump();
      fixes.add(const Success(sampleLocation));
      await tester.pump();
      final context = tester.element(find.byType(MapCanvas));
      final renderer = context.read<MapLibreRenderer>();
      final bloc = context.read<MapBloc>();
      final native = NativeMapHarness();
      final widget = tester.widget<MapLibreMap>(find.byType(MapLibreMap));
      widget.onMapCreated!(native.controller);
      widget.onStyleLoadedCallback!();
      await tester.pump();
      expect(bloc.state.mapReady, isTrue);
      expect(bloc.state.scene.layer?.places, hasLength(1));
      expect(bloc.state.scene.location, sampleLocation);
      expect(native.sources, isNotEmpty);

      // Observers that join after native readiness receive the current status.
      MapRenderStatus? observed;
      final disposed = Completer<void>();
      final subscription = renderer.statuses.listen(
        (status) => observed = status,
        onDone: disposed.complete,
      );
      await tester.pump();
      expect(observed, MapRenderStatus.ready);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(Duration.zero);
      expect(bloc.isClosed, isTrue);
      expect(fixes.hasListener, isFalse);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
      expect(disposed.isCompleted, isTrue);
      verifyNever(native.controller.dispose);
      await subscription.cancel();
    },
  );
}
