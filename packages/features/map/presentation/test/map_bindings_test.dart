import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_bloc.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_event.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_state.dart';
import 'package:map_presentation/src/map/canvas/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/canvas/models/map_canvas_status.dart';
import 'package:map_presentation/src/map/pages/map_view.dart';
import 'package:mocktail/mocktail.dart';

import 'support/map_fixtures.dart';

class MockMapBloc extends MockBloc<MapEvent, MapState> implements MapBloc {}

class MockCanvasBloc extends MockBloc<MapCanvasEvent, MapCanvasState>
    implements MapCanvasBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(const MapLocationActionRequested());
    registerFallbackValue(const MapCanvasSelectionCleared());
  });

  testWidgets('screen bindings forward content and dispatch user actions', (
    tester,
  ) async {
    final data = MockMapBloc();
    final canvas = MockCanvasBloc();
    final states = StreamController<MapState>.broadcast();
    addTearDown(states.close);
    whenListen(data, states.stream, initialState: const MapState());
    whenListen(
      canvas,
      const Stream<MapCanvasState>.empty(),
      initialState: const MapCanvasState(status: MapCanvasStatus.ready),
    );
    await tester.pumpWidget(
      FluentApp(
        theme: AppTheme.light(),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<MapBloc>.value(value: data),
            BlocProvider<MapCanvasBloc>.value(value: canvas),
          ],
          child: const MapView(canvas: ColoredBox(color: Colors.white)),
        ),
      ),
    );

    final loaded = MapState(layer: sampleLayer, loadingLayer: false);
    states.add(loaded);
    await tester.pumpAndSettle();
    expect(find.text('1 tempat untuk dijelajahi'), findsOneWidget);
    final layerEvent = verify(() => canvas.add(captureAny())).captured.single;
    expect(
      layerEvent,
      isA<MapCanvasContentChanged>().having(
        (event) => event.content,
        'content',
        loaded.content,
      ),
    );

    await tester.tap(find.text('Lokasi saya'));
    verify(() => data.add(any(that: isA<MapLocationActionRequested>())))
        .called(1);
    verify(
      () => canvas.add(
        any(
          that: isA<MapCanvasFocusRequested>().having(
            (event) => event.focus,
            'focus',
            MapCameraFocus.userLocation,
          ),
        ),
      ),
    ).called(1);
    states.add(loaded.copyWith(locating: true));
    await tester.pump();
    // Loading messages should not schedule another native data update.
    verifyNever(() => canvas.add(any()));
    expect(tester.widget<AppButton>(find.byType(AppButton)).isLoading, isTrue);

    await tester.tap(find.bySemanticsLabel('Lihat semua tempat'));
    verify(
      () => canvas.add(
        any(
          that: isA<MapCanvasFocusRequested>().having(
            (event) => event.focus,
            'focus',
            MapCameraFocus.places,
          ),
        ),
      ),
    ).called(1);
    final located = loaded.copyWith(location: sampleLocation);
    states.add(located);
    await tester.pumpAndSettle();
    expect(find.textContaining('akurasi ±12 m'), findsOneWidget);
    final locationEvent = verify(() => canvas.add(captureAny()))
        .captured
        .single;
    expect(
      locationEvent,
      isA<MapCanvasContentChanged>().having(
        (event) => event.content,
        'content',
        located.content,
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
