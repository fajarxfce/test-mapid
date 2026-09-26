import 'dart:async';
import 'dart:math';

import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/bindings/map_canvas_binding.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/models/map_scene.dart';
import 'package:map_presentation/src/map/rendering/map_renderer.dart';

import 'support/fake_map_renderer.dart';
import 'support/fake_repositories.dart';
import 'support/map_fixtures.dart';

void main() {
  late FakeMapRenderer renderer;
  late FakeMapRepository maps;
  late StreamController<Result<LocationFix>> fixes;
  late MapBloc bloc;
  late MapCanvasBinding binding;
  setUp(() {
    renderer = FakeMapRenderer();
    maps = FakeMapRepository();
    fixes = StreamController<Result<LocationFix>>.broadcast();
    final locations = FakeLocationRepository()..updates = () => fixes.stream;
    final access = FakeLocationAccessRepository();
    bloc = MapBloc(
      LoadMapLayer(maps),
      WatchLocation(locations, access, const FakeAppLifecycleRepository()),
      OpenLocationSettings(access),
    );
    binding = MapCanvasBinding(
      renderer: renderer,
      initialScene: bloc.state.scene,
      scenes: bloc.stream.map((state) => state.scene),
      effects: bloc.effects,
      onEvent: bloc.add,
    );
    renderer.scenes.clear();
  });
  tearDown(() async {
    await binding.close();
    await bloc.close();
    await renderer.close();
    await fixes.close();
  });
  Future<void> settle() => Future<void>.delayed(Duration.zero);
  Future<void> load([MapLayer? layer]) async {
    maps.response = () async => Success(layer ?? sampleLayer);
    bloc.add(const MapLayerRequested());
    await settle();
  }

  Future<void> selectPlace() async {
    await load();
    bloc.add(const MapTapped(Point(20, 20)));
    await settle();
    expect(bloc.state.selected?.name, 'Museum');
  }

  test(
    'panning stops follow once and the location action restores it',
    () async {
      bloc.add(const MapFocusRequested(MapCameraFocus.userLocation));
      bloc.add(const MapPanned());
      bloc.add(const MapPanned());
      await settle();
      expect(bloc.state.scene.focus, MapCameraFocus.free);
      expect(renderer.scenes.map((scene) => scene.focus), [
        MapCameraFocus.userLocation,
        MapCameraFocus.free,
      ]);
      bloc.add(const MapLocationActionRequested());
      await settle();
      expect(bloc.state.scene.focus, MapCameraFocus.userLocation);
      expect(renderer.scenes.last.focus, MapCameraFocus.userLocation);
    },
  );

  test('publishes desired data before a native map exists', () async {
    await load();
    bloc.add(const MapLocationRequested());
    await settle();
    fixes.add(const Success(sampleLocation));
    await settle();
    expect(bloc.state.scene.layer, sampleLayer);
    expect(bloc.state.scene.location, sampleLocation);
    expect(renderer.scenes.last, bloc.state.scene);
    expect(bloc.state.renderStatus, MapRenderStatus.waitingForMap);
  });

  test('native status changes preserve content, focus and popup', () async {
    await selectPlace();
    bloc.add(const MapFocusRequested(MapCameraFocus.userLocation));
    await settle();
    final scene = bloc.state.scene;
    renderer.updates.add(MapRenderStatus.renderingFailure);
    await settle();
    expect(bloc.state.scene, scene);
    expect(bloc.state.selected?.name, 'Museum');
    expect(bloc.state.mapError, isNotNull);
    renderer.updates.add(MapRenderStatus.ready);
    await settle();
    expect(bloc.state.mapReady, isTrue);
    expect(bloc.state.mapError, isNull);
  });

  test(
    'binding observes status and releases it without owning the renderer',
    () async {
      await settle();
      renderer.updates.add(MapRenderStatus.ready);
      await settle();
      expect(bloc.state.mapReady, isTrue);
      await binding.close();
      await bloc.close();
      expect(renderer.updates.hasListener, isFalse);
      expect(
        renderer.closed,
        isFalse,
        reason: 'The route owns adapter disposal',
      );
    },
  );

  test(
    'repeated focus requests recenter even when scene values are equal',
    () async {
      bloc.add(const MapFocusRequested(MapCameraFocus.places));
      bloc.add(const MapFocusRequested(MapCameraFocus.places));
      await settle();
      expect(renderer.focuses, hasLength(2));
      expect(renderer.focuses.first, renderer.focuses.last);
    },
  );

  test('late GPS preserves newer focus and an open popup', () async {
    await selectPlace();
    bloc.add(const MapLocationRequested());
    await settle();
    bloc.add(const MapFocusRequested(MapCameraFocus.userLocation));
    bloc.add(const MapFocusRequested(MapCameraFocus.places));
    fixes.add(const Success(sampleLocation));
    await settle();
    expect(bloc.state.scene.focus, MapCameraFocus.places);
    expect(renderer.scenes.last.location, sampleLocation);
    expect(bloc.state.selected?.address, 'Jalan Museum');
  });

  test('selects, dismisses, reselects and clears a background tap', () async {
    await selectPlace();
    bloc.add(const MapSelectionCleared());
    await settle();
    expect(bloc.state.selected, isNull);
    bloc.add(const MapTapped(Point(20, 20)));
    await settle();
    expect(bloc.state.selected?.name, 'Museum');
    renderer.pick = (_) async => const Success(null);
    bloc.add(const MapTapped(Point(40, 40)));
    await settle();
    expect(bloc.state.selected, isNull);
  });

  test('a slow earlier tap cannot override the latest tap', () async {
    await load();
    final pending = Completer<Result<String?>>();
    renderer.pick = (point) =>
        point.x == 20 ? pending.future : Future.value(const Success(null));
    bloc.add(const MapTapped(Point(20, 20)));
    await settle();
    bloc.add(const MapTapped(Point(40, 40)));
    await settle();
    pending.complete(const Success('place-1'));
    await settle();
    expect(bloc.state.selected, isNull);
  });

  test('a pending pick does not reopen a dismissed popup', () async {
    await selectPlace();
    final pending = Completer<Result<String?>>();
    renderer.pick = (_) => pending.future;
    bloc.add(const MapTapped(Point(20, 20)));
    await settle();
    bloc.add(const MapSelectionCleared());
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
      bloc.add(const MapTapped(Point(20, 20)));
      await settle();
      await load(MapLayer(name: 'Reloaded', places: []));
      pending.complete(const Success('place-1'));
      await settle();
      expect(bloc.state.selected, isNull);
    },
  );

  test('a failed pick preserves current selection', () async {
    await selectPlace();
    renderer.pick = (_) async => const FailureResult(
      Failure(FailureKind.unexpected, 'Native query failed'),
    );
    bloc.add(const MapTapped(Point(20, 20)));
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
      bloc.add(const MapTapped(Point(20, 20)));
      await settle();
      await load(MapLayer(name: sampleLayer.name, places: [copySamplePlace()]));
      expect(bloc.state.selected, same(selected));
      pending.complete(const Success('place-1'));
      await settle();
      expect(bloc.state.selected?.id, samplePlace.id);
    },
  );

  test('refresh updates popup attributes by stable ID', () async {
    await selectPlace();
    await load(
      MapLayer(
        name: sampleLayer.name,
        places: [copySamplePlace(name: 'Renamed museum')],
      ),
    );
    expect(bloc.state.selected?.id, samplePlace.id);
    expect(bloc.state.selected?.name, 'Renamed museum');
  });

  test(
    'close cancels status, GPS and pending picks without disposing the adapter',
    () async {
      bloc.add(const MapLocationRequested());
      await selectPlace();
      final pending = Completer<Result<String?>>();
      renderer.pick = (_) => pending.future;
      bloc.add(const MapTapped(Point(20, 20)));
      await settle();
      await binding.close();
      await bloc.close();
      expect(renderer.closed, isFalse);
      expect(renderer.updates.hasListener, isFalse);
      expect(fixes.hasListener, isFalse);
      pending.complete(const Success(null));
      await settle();
      expect(bloc.state.selected?.name, 'Museum');
    },
  );

  test(
    'late layer completion retains GPS, camera intent and native status',
    () async {
      final pending = Completer<Result<MapLayer>>();
      maps.response = () => pending.future;
      bloc.add(const MapLayerRequested());
      bloc.add(const MapLocationRequested());
      await settle();
      fixes.add(const Success(sampleLocation));
      bloc.add(const MapPanned());
      renderer.updates.add(MapRenderStatus.ready);
      await settle();
      pending.complete(Success(sampleLayer));
      await settle();
      expect(
        bloc.state.scene,
        MapScene(
          layer: sampleLayer,
          location: sampleLocation,
          focus: MapCameraFocus.free,
        ),
      );
      expect(bloc.state.mapReady, isTrue);
      expect(renderer.scenes.last, bloc.state.scene);
    },
  );

  test('native commands are independent of a pending layer request', () async {
    final pending = Completer<Result<MapLayer>>();
    maps.response = () => pending.future;
    bloc.add(const MapLayerRequested());
    bloc.add(const MapZoomRequested(1));
    bloc.add(const MapStyleReloadRequested());
    await settle();
    expect(renderer.zooms, [1]);
    expect(renderer.styleReloads, 1);
    await binding.close();
    await bloc.close();
    pending.complete(Success(sampleLayer));
    await settle();
    expect(renderer.scenes, isEmpty);
  });
}
