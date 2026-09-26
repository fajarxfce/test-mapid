import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/models/map_scene.dart';
import 'package:map_presentation/src/map/widgets/map_canvas.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'support/fake_map_renderer.dart';
import 'support/fake_repositories.dart';
import 'support/map_platform_view.dart';

void main() {
  late MapBloc bloc;
  late FakeMapRenderer renderer;
  late int nativeTaps;
  late int nativeDragUpdates;

  setUp(() {
    renderer = FakeMapRenderer();
    final locations = FakeLocationRepository();
    bloc = MapBloc(
      LoadMapLayer(FakeMapRepository()),
      WatchLocation(locations, const FakeAppLifecycleRepository()),
      OpenLocationSettings(locations),
      renderer,
    );
    nativeTaps = 0;
    nativeDragUpdates = 0;
    final previous = MapLibrePlatform.createInstance;
    final platform = TestMapPlatformView(
      surface: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => nativeTaps++,
        onPanUpdate: (_) => nativeDragUpdates++,
        child: const SizedBox.expand(),
      ),
    );
    MapLibrePlatform.createInstance = () => platform;
    addTearDown(() async {
      await bloc.close();
      await renderer.close();
      MapLibrePlatform.createInstance = previous;
    });
  });

  Future<void> mount(WidgetTester tester) async {
    bloc.add(const MapFocusRequested(MapCameraFocus.userLocation));
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: BlocProvider.value(value: bloc, child: const MapCanvas()),
      ),
    );
    await tester.pump();
    expect(bloc.state.scene.focus, MapCameraFocus.userLocation);
  }

  testWidgets('tap jitter preserves follow and reaches the map surface', (
    tester,
  ) async {
    await mount(tester);
    final finger = await tester.startGesture(const Offset(200, 200));
    await finger.moveBy(const Offset(3, 2));
    await finger.up();
    await tester.pump();
    expect(bloc.state.scene.focus, MapCameraFocus.userLocation);
    expect(renderer.scenes, isEmpty);
    expect(nativeTaps, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'intentional drag stops follow once without stealing map gestures',
    (tester) async {
      await mount(tester);
      final finger = await tester.startGesture(const Offset(200, 200));
      await finger.moveBy(const Offset(60, 0));
      await finger.moveBy(const Offset(60, 0));
      await finger.up();
      await tester.pump();
      expect(bloc.state.scene.focus, MapCameraFocus.free);
      expect(renderer.scenes, hasLength(1));
      expect(nativeDragUpdates, greaterThan(0));
      expect(nativeTaps, 0);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('cancellation and disposal release pointer tracking', (
    tester,
  ) async {
    await mount(tester);
    final first = await tester.startGesture(const Offset(200, 200));
    await first.moveBy(const Offset(3, 2));
    await first.cancel();
    final next = await tester.startGesture(const Offset(500, 300));
    await next.moveBy(const Offset(3, 2));
    await tester.pump();
    expect(renderer.scenes, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    await next.moveBy(const Offset(100, 0));
    await next.up();
    await tester.pump();
    expect(renderer.scenes, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
