import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';
import 'package:map_presentation/src/map/canvas/map_canvas.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mocktail/mocktail.dart';

import 'support/map_platform_view.dart';

class MockMapBloc extends MockBloc<MapEvent, MapState> implements MapBloc {}

void main() {
  setUpAll(() => registerFallbackValue(const MapPanned()));
  late MockMapBloc bloc;
  late int nativeTaps;
  late int nativeDragUpdates;

  setUp(() {
    bloc = MockMapBloc();
    whenListen(
      bloc,
      const Stream<MapState>.empty(),
      initialState: const MapState(),
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
      MapLibrePlatform.createInstance = previous;
    });
  });

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: BlocProvider<MapBloc>.value(
          value: bloc,
          child: const MapCanvas(),
        ),
      ),
    );
    await tester.pump();
    verifyNever(() => bloc.add(any(that: isA<MapPanned>())));
  }

  testWidgets('tap jitter preserves follow and reaches the map surface', (
    tester,
  ) async {
    await mount(tester);
    final finger = await tester.startGesture(const Offset(200, 200));
    await finger.moveBy(const Offset(3, 2));
    await finger.up();
    await tester.pump();
    verifyNever(() => bloc.add(any(that: isA<MapPanned>())));
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
      verify(() => bloc.add(any(that: isA<MapPanned>()))).called(1);
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
    verifyNever(() => bloc.add(any(that: isA<MapPanned>())));
    await tester.pumpWidget(const SizedBox.shrink());
    await next.moveBy(const Offset(100, 0));
    await next.up();
    await tester.pump();
    verifyNever(() => bloc.add(any(that: isA<MapPanned>())));
    expect(tester.takeException(), isNull);
  });
}
