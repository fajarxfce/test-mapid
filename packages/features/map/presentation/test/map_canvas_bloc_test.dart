import 'dart:async';
import 'dart:math';

import 'package:core_common/core_common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_bloc.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_event.dart';
import 'package:map_presentation/src/map/canvas/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/models/map_content.dart';
import 'package:map_presentation/src/map/rendering/map_renderer.dart';

import 'support/fake_map_renderer.dart';
import 'support/map_fixtures.dart';

void main() {
  late FakeMapRenderer renderer;
  late MapCanvasBloc bloc;
  setUp(() {
    renderer = FakeMapRenderer();
    bloc = MapCanvasBloc(renderer);
  });
  tearDown(() async {
    await bloc.close();
    await renderer.close();
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test(
    'panning stops camera follow once and the location action restores it',
    () async {
      bloc.add(const MapCanvasFocusRequested(MapCameraFocus.userLocation));
      bloc.add(const MapCanvasPanned());
      bloc.add(const MapCanvasPanned());
      await settle();
      expect(bloc.state.scene.focus, MapCameraFocus.free);
      expect(renderer.scenes, hasLength(1));
      bloc.add(const MapCanvasFocusRequested(MapCameraFocus.userLocation));
      await settle();
      expect(bloc.state.scene.focus, MapCameraFocus.userLocation);
      expect(renderer.focuses, hasLength(2));
    },
  );
  Future<void> selectPlace() async {
    bloc.add(MapCanvasContentChanged(MapContent(layer: sampleLayer)));
    bloc.add(const MapCanvasTapped(Point(20, 20)));
    await settle();
    expect(bloc.state.selected?.name, 'Museum');
  }

  test('publishes the desired scene before a native map exists', () async {
    final content = MapContent(layer: sampleLayer, location: sampleLocation);
    bloc.add(MapCanvasContentChanged(content));
    await settle();
    expect(bloc.state.scene.content, content);
    expect(renderer.scenes.single, bloc.state.scene);
    expect(bloc.state.renderStatus, MapRenderStatus.waitingForMap);
  });

  test(
    'native status changes preserve current content, focus and popup',
    () async {
      bloc.add(const MapCanvasStarted());
      await selectPlace();
      bloc.add(const MapCanvasFocusRequested(MapCameraFocus.userLocation));
      await settle();
      final scene = bloc.state.scene;
      renderer.updates.add(MapRenderStatus.renderingFailure);
      await settle();
      expect(bloc.state.scene, scene);
      expect(bloc.state.selected?.name, 'Museum');
      expect(bloc.state.errorMessage, isNotNull);
      renderer.updates.add(MapRenderStatus.ready);
      await settle();
      expect(bloc.state.ready, isTrue);
      expect(bloc.state.errorMessage, isNull);
    },
  );

  test('starting twice keeps one status observer', () async {
    bloc.add(const MapCanvasStarted());
    bloc.add(const MapCanvasStarted());
    await settle();
    renderer.updates.add(MapRenderStatus.ready);
    await settle();
    expect(bloc.state.ready, isTrue);
    await bloc.close();
    expect(renderer.updates.hasListener, isFalse);
    expect(renderer.closed, isFalse, reason: 'The route owns adapter disposal');
  });

  test(
    'repeating focus still requests recentering after a manual pan',
    () async {
      bloc.add(const MapCanvasFocusRequested(MapCameraFocus.places));
      bloc.add(const MapCanvasFocusRequested(MapCameraFocus.places));
      await settle();
      expect(renderer.focuses, hasLength(2));
      expect(renderer.focuses.first, renderer.focuses.last);
    },
  );

  test('late GPS preserves newer focus and an open popup', () async {
    await selectPlace();
    bloc.add(const MapCanvasFocusRequested(MapCameraFocus.userLocation));
    bloc.add(const MapCanvasFocusRequested(MapCameraFocus.places));
    bloc.add(
      MapCanvasContentChanged(
        MapContent(layer: sampleLayer, location: sampleLocation),
      ),
    );
    await settle();
    expect(bloc.state.scene.focus, MapCameraFocus.places);
    expect(renderer.scenes.last.content.location, sampleLocation);
    expect(bloc.state.selected?.address, 'Jalan Museum');
  });

  test('selects, dismisses, reselects and clears a background tap', () async {
    await selectPlace();
    bloc.add(const MapCanvasSelectionCleared());
    await settle();
    expect(bloc.state.selected, isNull);
    bloc.add(const MapCanvasTapped(Point(20, 20)));
    await settle();
    expect(bloc.state.selected?.name, 'Museum');
    renderer.pick = (_) async => const Success(null);
    bloc.add(const MapCanvasTapped(Point(40, 40)));
    await settle();
    expect(bloc.state.selected, isNull);
  });

  test('a slow earlier tap cannot override the latest tap', () async {
    bloc.add(MapCanvasContentChanged(MapContent(layer: sampleLayer)));
    final pending = Completer<Result<String?>>();
    renderer.pick = (point) =>
        point.x == 20 ? pending.future : Future.value(const Success(null));
    bloc.add(const MapCanvasTapped(Point(20, 20)));
    await settle();
    bloc.add(const MapCanvasTapped(Point(40, 40)));
    await settle();
    pending.complete(const Success('place-1'));
    await settle();
    expect(bloc.state.selected, isNull);
  });

  test('a pending pick does not reopen a dismissed popup', () async {
    await selectPlace();
    final pending = Completer<Result<String?>>();
    renderer.pick = (_) => pending.future;
    bloc.add(const MapCanvasTapped(Point(20, 20)));
    await settle();
    bloc.add(const MapCanvasSelectionCleared());
    await settle();
    pending.complete(const Success('place-1'));
    await settle();
    expect(bloc.state.selected, isNull);
  });

  test(
    'removing a selected place clears it and invalidates a pending pick',
    () async {
      await selectPlace();
      final pending = Completer<Result<String?>>();
      renderer.pick = (_) => pending.future;
      bloc.add(const MapCanvasTapped(Point(20, 20)));
      await settle();
      bloc.add(
        MapCanvasContentChanged(
          MapContent(
            layer: MapLayer(name: 'Reloaded', places: []),
          ),
        ),
      );
      await settle();
      pending.complete(const Success('place-1'));
      await settle();
      expect(bloc.state.selected, isNull);
    },
  );

  test('a failed pick preserves the current selection', () async {
    await selectPlace();
    renderer.pick = (_) async => const FailureResult(
      Failure(FailureKind.unexpected, 'Native query failed'),
    );
    bloc.add(const MapCanvasTapped(Point(20, 20)));
    await settle();
    expect(bloc.state.selected?.name, 'Museum');
  });

  test(
    'an identical refresh preserves the popup and pending selection',
    () async {
      await selectPlace();
      final selected = bloc.state.selected;
      final pending = Completer<Result<String?>>();
      renderer.pick = (_) => pending.future;
      bloc.add(const MapCanvasTapped(Point(20, 20)));
      await settle();
      bloc.add(
        MapCanvasContentChanged(
          MapContent(
            layer: MapLayer(
              name: sampleLayer.name,
              places: [copySamplePlace()],
            ),
          ),
        ),
      );
      await settle();
      expect(bloc.state.selected, same(selected));
      pending.complete(const Success('place-1'));
      await settle();
      expect(bloc.state.selected?.id, samplePlace.id);
    },
  );

  test(
    'refresh updates popup attributes by stable ID while it remains present',
    () async {
      await selectPlace();
      bloc.add(
        MapCanvasContentChanged(
          MapContent(
            layer: MapLayer(
              name: sampleLayer.name,
              places: [copySamplePlace(name: 'Renamed museum')],
            ),
          ),
        ),
      );
      await settle();
      expect(bloc.state.selected?.id, samplePlace.id);
      expect(bloc.state.selected?.name, 'Renamed museum');
    },
  );

  test('close cancels observation and pending picks without disposing the route adapter', () async {
    bloc.add(const MapCanvasStarted());
    await selectPlace();
    final pending = Completer<Result<String?>>();
    renderer.pick = (_) => pending.future;
    bloc.add(const MapCanvasTapped(Point(20, 20)));
    await settle();
    await bloc.close();
    expect(renderer.closed, isFalse);
    expect(renderer.updates.hasListener, isFalse);
    pending.complete(const Success(null));
    await settle();
    expect(bloc.state.selected?.name, 'Museum');
  });
}
