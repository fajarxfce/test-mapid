import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';
import 'package:map_presentation/src/map/canvas/map_canvas.dart';
import 'package:map_presentation/src/map/canvas/maplibre/maplibre_adapter.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'support/map_platform_view.dart';

class MockMapBloc extends MockBloc<MapEvent, MapState> implements MapBloc {}

void main() {
  testWidgets('production canvas builds with SDK assertions enabled', (
    tester,
  ) async {
    final previous = MapLibrePlatform.createInstance;
    final platform = TestMapPlatformView();
    MapLibrePlatform.createInstance = () => platform;
    addTearDown(() => MapLibrePlatform.createInstance = previous);

    final bloc = MockMapBloc();
    whenListen(
      bloc,
      const Stream<MapState>.empty(),
      initialState: const MapState(),
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: BlocProvider<MapBloc>.value(
          value: bloc,
          child: const MapCanvas(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(MapLibreMap), findsOneWidget);
    expect(platform.creationParams?['styleString'], MapLibreAdapter.styleUrl);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
