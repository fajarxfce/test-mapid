import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_bloc.dart';
import 'package:map_presentation/src/map/canvas/bloc/map_canvas_event.dart';
import 'package:map_presentation/src/map/canvas/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/canvas/models/map_canvas_failure.dart';
import 'package:map_presentation/src/map/canvas/models/map_canvas_status.dart';
import 'package:map_presentation/src/map/models/map_content.dart';

import 'support/fake_surface.dart';
import 'support/map_fixtures.dart';

void main() {
  late FakeSurfaceFactory factory;
  late MapCanvasBloc bloc;
  setUp(() {
    factory = FakeSurfaceFactory();
    bloc = MapCanvasBloc(factory);
  });
  tearDown(() async {
    await bloc.close();
  });
  Future<void> attach() async {
    final ready = bloc.stream.firstWhere((state) => state.ready);
    bloc.add(MapCanvasAttached(TestMapController()));
    bloc.add(const MapCanvasStyleLoaded());
    await ready;
  }

  Future<void> settle() async {
    await Future<void>.delayed(Duration.zero);
  }

  test(
    'retains data before native creation and restores it after style load',
    () async {
      bloc.add(
        MapCanvasContentChanged(
          MapContent(layer: sampleLayer, location: sampleLocation),
        ),
      );
      await settle();
      expect(factory.surface.calls, isEmpty);
      await attach();
      expect(factory.surface.calls, ['places:Jogja', 'location', 'fit:Jogja']);
    },
  );

  test(
    'does not write sources between native creation and style readiness',
    () async {
      bloc.add(MapCanvasAttached(TestMapController()));
      bloc.add(MapCanvasContentChanged(MapContent(layer: sampleLayer)));
      await settle();
      expect(bloc.state.content.layer, same(sampleLayer));
      expect(factory.surface.calls, isEmpty);
      final ready = bloc.stream.firstWhere((state) => state.ready);
      bloc.add(const MapCanvasStyleLoaded());
      await ready;
      expect(factory.surface.calls, ['places:Jogja', 'fit:Jogja']);
    },
  );

  test(
    'style replacement restores sources and the latest camera focus',
    () async {
      bloc.add(
        MapCanvasContentChanged(
          MapContent(layer: sampleLayer, location: sampleLocation),
        ),
      );
      await attach();
      bloc.add(const MapCanvasFocusRequested(MapCameraFocus.userLocation));
      await settle();
      factory.surface.calls.clear();
      bloc.add(const MapCanvasStyleReloadRequested());
      bloc.add(const MapCanvasStyleLoaded());
      await settle();
      expect(factory.surface.calls, [
        'reload',
        'places:Jogja',
        'location',
        'center',
      ]);
      expect(bloc.state.ready, isTrue);
    },
  );

  test(
    'late GPS data respects a newer request to show the tourism layer',
    () async {
      bloc.add(MapCanvasContentChanged(MapContent(layer: sampleLayer)));
      await attach();
      factory.surface.calls.clear();
      bloc.add(const MapCanvasFocusRequested(MapCameraFocus.userLocation));
      bloc.add(const MapCanvasFocusRequested(MapCameraFocus.places));
      bloc.add(
        MapCanvasContentChanged(
          MapContent(layer: sampleLayer, location: sampleLocation),
        ),
      );
      await settle();
      expect(factory.surface.calls, ['fit:Jogja', 'location']);
      expect(bloc.state.focus, MapCameraFocus.places);
    },
  );

  test('selects, clears, and reselects the same feature', () async {
    bloc.add(MapCanvasContentChanged(MapContent(layer: sampleLayer)));
    await attach();
    bloc.add(const MapCanvasTapped(Point(20, 20)));
    await settle();
    expect(bloc.state.selected?.name, 'Museum');
    expect(bloc.state.selected?.address, 'Jalan Museum');
    bloc.add(const MapCanvasSelectionCleared());
    await settle();
    expect(bloc.state.selected, isNull);
    bloc.add(const MapCanvasTapped(Point(20, 20)));
    await settle();
    expect(bloc.state.selected?.name, 'Museum');
    factory.surface.picked = null;
    bloc.add(const MapCanvasTapped(Point(40, 40)));
    await settle();
    expect(bloc.state.selected, isNull);
  });

  test(
    'GPS changes preserve the open popup without rewriting tourism data',
    () async {
      bloc.add(MapCanvasContentChanged(MapContent(layer: sampleLayer)));
      await attach();
      bloc.add(const MapCanvasTapped(Point(20, 20)));
      await settle();
      factory.surface.calls.clear();
      bloc.add(
        MapCanvasContentChanged(
          MapContent(layer: sampleLayer, location: sampleLocation),
        ),
      );
      await settle();
      expect(factory.surface.calls, ['location']);
      expect(bloc.state.selected?.name, 'Museum');
    },
  );

  test('native writes and camera commands cannot interleave', () async {
    await attach();
    final pending = Completer<void>();
    factory.surface.onShowPlaces = (_) => pending.future;
    bloc.add(MapCanvasContentChanged(MapContent(layer: sampleLayer)));
    bloc.add(const MapCanvasZoomRequested(1));
    await settle();
    expect(factory.surface.calls, ['places:Jogja']);
    pending.complete();
    await settle();
    expect(factory.surface.calls, ['places:Jogja', 'fit:Jogja', 'zoom:1.0']);
  });

  test(
    'a render failure retains content for a successful style retry',
    () async {
      await attach();
      factory.surface.onShowPlaces = (_) async =>
          throw PlatformException(code: 'failed');
      bloc.add(MapCanvasContentChanged(MapContent(layer: sampleLayer)));
      await settle();
      expect(bloc.state.failure, MapCanvasFailure.rendering);
      expect(bloc.state.content.layer, same(sampleLayer));
      factory.surface.onShowPlaces = null;
      bloc.add(const MapCanvasStyleReloadRequested());
      bloc.add(const MapCanvasStyleLoaded());
      await settle();
      expect(bloc.state.ready, isTrue);
      expect(bloc.state.failure, isNull);
    },
  );

  test(
    'recreating the native map keeps data and binds a new surface',
    () async {
      bloc.add(MapCanvasContentChanged(MapContent(layer: sampleLayer)));
      await attach();
      final oldSurface = factory.surface;
      oldSurface.isDisposed = true;
      factory.surface = FakeMapSurface();
      await attach();
      expect(factory.surface.calls, ['places:Jogja', 'fit:Jogja']);
      expect(oldSurface.calls, ['places:Jogja', 'fit:Jogja']);
    },
  );

  testWidgets(
    'style timeout is recoverable and an old timeout cannot fail a new load',
    (tester) async {
      final timedBloc = MapCanvasBloc(factory);
      addTearDown(timedBloc.close);
      timedBloc.add(MapCanvasAttached(TestMapController()));
      await tester.pump();
      timedBloc.add(const MapCanvasStyleTimedOut());
      await tester.pump();
      expect(timedBloc.state.status, MapCanvasStatus.loadingStyle);
      await tester.pump(const Duration(seconds: 26));
      expect(timedBloc.state.failure, MapCanvasFailure.styleTimeout);
      timedBloc.add(const MapCanvasStyleReloadRequested());
      timedBloc.add(const MapCanvasStyleLoaded());
      await tester.pump();
      expect(timedBloc.state.ready, isTrue);
    },
  );

  test(
    'a pending native failure after disposal does not emit a late state',
    () async {
      await attach();
      final pending = Completer<void>();
      factory.surface.onShowPlaces = (_) => pending.future;
      bloc.add(MapCanvasContentChanged(MapContent(layer: sampleLayer)));
      await settle();
      final closing = bloc.close();
      pending.completeError(PlatformException(code: 'disposed'));
      await closing;
      expect(bloc.state.failure, isNull);
    },
  );

  test(
    'closing during a successful write prevents subsequent camera operations',
    () async {
      await attach();
      final pending = Completer<void>();
      factory.surface.onShowPlaces = (_) => pending.future;
      bloc.add(
        MapCanvasContentChanged(
          MapContent(layer: sampleLayer, location: sampleLocation),
        ),
      );
      await settle();
      final closing = bloc.close();
      pending.complete();
      await closing;
      expect(factory.surface.calls, ['places:Jogja']);
    },
  );

  test(
    'closing discards native attachment events still in the queue',
    () async {
      await attach();
      final pending = Completer<void>();
      factory.surface.onShowPlaces = (_) => pending.future;
      bloc.add(MapCanvasContentChanged(MapContent(layer: sampleLayer)));
      await settle();
      bloc.add(MapCanvasAttached(TestMapController()));
      final closing = bloc.close();
      pending.complete();
      await closing;
      expect(factory.creations, 1);
    },
  );
}
