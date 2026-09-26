import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/canvas/map_canvas_binding.dart';
import 'package:map_presentation/src/map/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/models/map_canvas_status.dart';

import 'support/fake_map_canvas.dart';
import 'support/fake_repositories.dart';
import 'support/map_fixtures.dart';

void main() {
  late FakeMapCanvas canvas;
  late FakeMapRepository maps;
  late StreamController<Result<LocationFix>> fixes;
  late MapBloc bloc;
  late MapCanvasBinding binding;
  setUp(() {
    canvas = FakeMapCanvas();
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
      canvas: canvas,
      initialLayer: bloc.state.layer,
      initialLocation: bloc.state.location,
      layers: bloc.stream.map((state) => state.layer),
      locations: bloc.stream.map((state) => state.location),
      effects: bloc.effects,
      onEvent: bloc.add,
    );
  });
  tearDown(() async {
    await binding.close();
    await bloc.close();
    await canvas.close();
    await fixes.close();
  });
  Future<void> settle() => Future<void>.delayed(Duration.zero);
  Future<void> load([MapLayer? layer]) async {
    maps.response = () async => Success(layer ?? sampleLayer);
    bloc.add(const MapLayerRequested());
    await settle();
  }

  test('data channels update independently and status does not trigger native writes', () async {
    await load();
    bloc.add(const MapLocationRequested());
    await settle();
    fixes.add(const Success(sampleLocation));
    await settle();
    expect(canvas.layers, [null, sampleLayer]);
    expect(canvas.locations, [null, sampleLocation]);
    canvas.statusUpdates.add(MapCanvasStatus.ready);
    await settle();
    expect(bloc.state.mapReady, isTrue);
    expect(canvas.layers, [null, sampleLayer]);
    expect(canvas.locations, [null, sampleLocation]);
    await load(MapLayer(name: sampleLayer.name, places: [copySamplePlace()]));
    expect(canvas.layers, [null, sampleLayer]);
  });

  test(
    'each explicit recenter is delivered while pan and zoom stay ordered',
    () async {
      bloc.add(const MapFocusRequested(MapCameraFocus.userLocation));
      bloc.add(const MapFocusRequested(MapCameraFocus.userLocation));
      bloc.add(const MapPanned());
      bloc.add(const MapZoomRequested(1));
      bloc.add(const MapCanvasRetryRequested());
      await settle();
      expect(canvas.focuses, [
        MapCameraFocus.userLocation,
        MapCameraFocus.userLocation,
        MapCameraFocus.free,
      ]);
      expect(canvas.zooms, [1]);
      expect(canvas.retries, 1);
    },
  );

  test(
    'native IDs select current domain values and background taps dismiss',
    () async {
      await load();
      canvas.selectedIds.add(samplePlace.id);
      await settle();
      expect(bloc.state.selected?.name, 'Museum');
      await load(
        MapLayer(
          name: 'Updated',
          places: [copySamplePlace(name: 'Updated museum')],
        ),
      );
      expect(bloc.state.selected?.name, 'Updated museum');
      canvas.selectedIds.add(null);
      await settle();
      expect(bloc.state.selected, isNull);
    },
  );

  test(
    'equal refresh preserves selection while removing its ID clears it',
    () async {
      await load();
      canvas.selectedIds.add(samplePlace.id);
      await settle();
      final selected = bloc.state.selected;
      await load(MapLayer(name: sampleLayer.name, places: [copySamplePlace()]));
      expect(bloc.state.selected, same(selected));
      await load(MapLayer(name: 'Empty', places: []));
      expect(bloc.state.selected, isNull);
      canvas.selectedIds.add(samplePlace.id);
      await settle();
      expect(bloc.state.selected, isNull);
    },
  );

  test('late layer completion preserves GPS and native availability', () async {
    final pending = Completer<Result<MapLayer>>();
    maps.response = () => pending.future;
    bloc.add(const MapLayerRequested());
    bloc.add(const MapLocationRequested());
    await settle();
    fixes.add(const Success(sampleLocation));
    canvas.statusUpdates.add(MapCanvasStatus.ready);
    await settle();
    pending.complete(Success(sampleLayer));
    await settle();
    expect(bloc.state.layer, sampleLayer);
    expect(bloc.state.location, sampleLocation);
    expect(bloc.state.mapReady, isTrue);
  });

  test('closing the binding disconnects both directions without owning Bloc or canvas', () async {
    bloc.add(const MapLocationRequested());
    await load();
    await binding.close();
    final layerCount = canvas.layers.length;
    final locationCount = canvas.locations.length;
    fixes.add(const Success(sampleLocation));
    canvas.selectedIds.add(samplePlace.id);
    canvas.statusUpdates.add(MapCanvasStatus.ready);
    bloc.add(const MapZoomRequested(1));
    await settle();
    expect(bloc.isClosed, isFalse);
    expect(canvas.closed, isFalse);
    expect(canvas.layers, hasLength(layerCount));
    expect(canvas.locations, hasLength(locationCount));
    expect(canvas.zooms, isEmpty);
    expect(bloc.state.selected, isNull);
    expect(bloc.state.mapReady, isFalse);
    await bloc.close();
    expect(fixes.hasListener, isFalse);
  });
}
