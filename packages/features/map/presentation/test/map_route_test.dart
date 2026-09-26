import 'dart:async';

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
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/canvas/map_canvas.dart';
import 'package:map_presentation/src/map/canvas/maplibre/maplibre_adapter.dart';
import 'package:map_presentation/src/map/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/models/map_canvas_status.dart';
import 'package:map_presentation/src/navigation/map_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart' hide Success;
import 'package:mocktail/mocktail.dart';

import 'support/annotation_map_harness.dart';
import 'support/fake_repositories.dart';
import 'support/map_fixtures.dart';
import 'support/map_platform_view.dart';

void main() {
  setUpAll(AnnotationMapHarness.registerFallbacks);

  late StreamController<Result<LocationFix>> fixes;
  late RootStackRouter router;
  setUp(() async {
    final container = GetIt.asNewInstance();
    fixes = StreamController<Result<LocationFix>>();
    final locations = FakeLocationRepository()..updates = () => fixes.stream;
    final access = FakeLocationAccessRepository();
    addTearDown(fixes.close);
    container.registerSingleton<GetIt>(container);
    container.registerFactory(() => LoadMapLayer(FakeMapRepository()));
    container.registerFactory(
      () =>
          WatchLocation(locations, access, const FakeAppLifecycleRepository()),
    );
    container.registerFactory(() => OpenLocationSettings(access));
    await MapPresentationPackageModule().init(GetItHelper(container));
    addTearDown(container.reset);
    final previousPlatform = MapLibrePlatform.createInstance;
    MapLibrePlatform.createInstance = TestMapPlatformView.new;
    addTearDown(() => MapLibrePlatform.createInstance = previousPlatform);
    router = RootStackRouter.build(routes: container<MapRouter>().routes);
    addTearDown(router.dispose);
  });

  testWidgets(
    'generated route DI shares one adapter and releases it when the route closes',
    (tester) async {
      await tester.pumpWidget(FluentApp.router(routerConfig: router.config()));
      await tester.pump();
      await tester.pump();
      fixes.add(const Success(sampleLocation));
      await tester.pump();
      final context = tester.element(find.byType(MapCanvas));
      final renderer = context.read<MapLibreAdapter>();
      final bloc = context.read<MapBloc>();
      final native = AnnotationMapHarness();
      final widget = tester.widget<MapLibreMap>(find.byType(MapLibreMap));
      widget.onMapCreated!(native.controller);
      widget.onStyleLoadedCallback!();
      await tester.pump();
      expect(bloc.state.mapReady, isTrue);
      expect(bloc.state.layer?.places, hasLength(1));
      expect(bloc.state.location, sampleLocation);
      expect(native.circles, isNotEmpty);

      native.cameraMoves.clear();
      bloc.add(const MapFocusRequested(MapCameraFocus.userLocation));
      await tester.pump();
      expect(
        native.cameraMoves,
        hasLength(1),
        reason: 'Changing focus issues one movement.',
      );
      bloc.add(const MapFocusRequested(MapCameraFocus.userLocation));
      await tester.pump();
      expect(
        native.cameraMoves,
        hasLength(2),
        reason: 'An equal-state recenter remains a one-time command.',
      );

      // Observers that join after native readiness receive the current status.
      MapCanvasStatus? observed;
      final disposed = Completer<void>();
      final subscription = renderer.statuses.listen(
        (status) => observed = status,
        onDone: disposed.complete,
      );
      await tester.pump();
      expect(observed, MapCanvasStatus.ready);
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

  testWidgets(
    'native creation timeout remounts the canvas without restarting page data',
    (tester) async {
      await tester.pumpWidget(FluentApp.router(routerConfig: router.config()));
      await tester.pump();
      fixes.add(const Success(sampleLocation));
      await tester.pump();
      final context = tester.element(find.byType(MapCanvas));
      final bloc = context.read<MapBloc>();
      final originalNativeState = tester.state(find.byType(MapLibreMap));
      final layer = bloc.state.layer;
      final location = bloc.state.location;
      expect(layer?.places, hasLength(1));
      expect(location, sampleLocation);

      await tester.pump(const Duration(seconds: 26));
      await tester.pump();
      expect(bloc.state.canvasStatus, MapCanvasStatus.creationTimeout);
      expect(find.byType(MapLibreMap), findsNothing);
      expect(originalNativeState.mounted, isFalse);
      expect(
        find.text('Peta belum dapat dimulai. Coba muat ulang peta.'),
        findsOneWidget,
      );
      expect(bloc.state.layer, same(layer));
      expect(bloc.state.location, same(location));
      expect(fixes.hasListener, isTrue);

      await tester.tap(find.text('Muat peta'));
      await tester.pump();
      await tester.pump();
      expect(bloc.state.canvasStatus, MapCanvasStatus.waitingForMap);
      expect(find.byType(MapLibreMap), findsOneWidget);
      expect(
        tester.state(find.byType(MapLibreMap)),
        isNot(same(originalNativeState)),
      );
      expect(context.read<MapBloc>(), same(bloc));
      expect(bloc.state.layer, same(layer));
      expect(bloc.state.location, same(location));

      final native = AnnotationMapHarness();
      final canvas = tester.widget<MapLibreMap>(find.byType(MapLibreMap));
      canvas.onMapCreated!(native.controller);
      canvas.onStyleLoadedCallback!();
      await tester.pump();
      expect(bloc.state.mapReady, isTrue);
      expect(
        native.circles.where((circle) => circle.data?['place_id'] != null),
        hasLength(1),
      );
      expect(
        native.circles.where(
          (circle) => circle.data?['role'] == 'user-location',
        ),
        hasLength(1),
      );
      expect(find.text('Muat peta'), findsNothing);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(bloc.isClosed, isTrue);
      expect(fixes.hasListener, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
