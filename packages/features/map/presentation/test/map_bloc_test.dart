import 'dart:async';
import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:core_common/core_common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';
import 'package:map_presentation/src/map/models/location_action.dart';
import 'package:map_presentation/src/map/rendering/map_libre_renderer.dart';

final layer = MapLayer(
  name: 'Jogja',
  places: [
    const MapPlace(
      id: 'place-1',
      name: 'Museum',
      address: 'Jalan Museum',
      city: 'Yogyakarta',
      district: 'Gondomanan',
      period: '2024',
      point: GeoPoint(latitude: -7.8, longitude: 110.36),
    ),
  ],
);
const location = UserLocation(
  point: GeoPoint(latitude: -6.2, longitude: 106.8),
  accuracyMeters: 12,
);

class _MapRepository implements MapRepository {
  Future<Result<MapLayer>> Function() response = () async => Success(layer);
  @override
  Future<Result<MapLayer>> loadLayer() => response();
}

class _LocationRepository implements UserLocationRepository {
  Result<UserLocation> result = const Success(location);
  LocationSettingsTarget? opened;
  @override
  Future<Result<UserLocation>> locate() async => result;
  @override
  Future<bool> openSettings(LocationSettingsTarget target) async {
    opened = target;
    return true;
  }
}

class _Renderer extends MapLibreRenderer {
  final calls = <String>[];
  String? picked = 'place-1';
  @override
  Future<void> renderLayer(MapLayer layer) async {
    calls.add('layer:${layer.name}');
  }

  @override
  Future<void> renderLocation(UserLocation location) async {
    calls.add('location');
  }

  @override
  Future<void> fitLayer(MapLayer layer) async {
    calls.add('fit');
  }

  @override
  Future<void> focusLocation(UserLocation location) async {
    calls.add('focus-location');
  }

  @override
  Future<String?> placeAt(Point<double> point) async => picked;
  @override
  Future<void> reloadStyle() async {
    calls.add('reload');
  }

  @override
  void detach() {
    calls.add('detach');
  }
}

void main() {
  late _MapRepository maps;
  late _LocationRepository locations;
  late _Renderer renderer;
  MapBloc createBloc() => MapBloc(
    LoadMapLayer(maps),
    LocateUser(locations),
    OpenLocationSettings(locations),
    renderer,
  );
  setUp(() {
    maps = _MapRepository();
    locations = _LocationRepository();
    renderer = _Renderer();
  });

  blocTest<MapBloc, MapState>(
    'data can arrive before the style without touching an unready map',
    build: createBloc,
    act: (bloc) async {
      final loaded = bloc.stream.firstWhere((state) => !state.loadingLayer);
      bloc.add(const MapLayerRequested());
      await loaded;
      expect(renderer.calls, isEmpty);
      bloc.add(const MapStyleLoaded());
    },
    verify: (bloc) {
      expect(bloc.state.placeCount, 1);
      expect(renderer.calls, containsAllInOrder(['layer:Jogja', 'fit']));
    },
  );

  blocTest<MapBloc, MapState>(
    'data arriving after style readiness is rendered and fitted',
    build: createBloc,
    act: (bloc) {
      bloc.add(const MapStyleLoaded());
      bloc.add(const MapLayerRequested());
    },
    wait: const Duration(milliseconds: 20),
    verify: (bloc) {
      expect(bloc.state.placeCount, 1);
      expect(renderer.calls, containsAllInOrder(['layer:Jogja', 'fit']));
    },
  );

  blocTest<MapBloc, MapState>(
    'GPS denial does not prevent the tourism layer loading',
    setUp: () => locations.result = const FailureResult(
      Failure(FailureKind.permissionPermanentlyDenied, 'Permission required'),
    ),
    build: createBloc,
    act: (bloc) {
      bloc.add(const MapStyleLoaded());
      bloc.add(const MapLayerRequested());
      bloc.add(const MapLocationRequested());
    },
    wait: const Duration(milliseconds: 20),
    verify: (bloc) {
      expect(bloc.state.placeCount, 1);
      expect(bloc.state.locationAction, LocationAction.appSettings);
      expect(bloc.state.locating, isFalse);
    },
  );

  blocTest<MapBloc, MapState>(
    'location can arrive before the style and is restored on style load',
    build: createBloc,
    act: (bloc) async {
      final fixed = bloc.stream.firstWhere(
        (state) => state.locationMessage != null,
      );
      bloc.add(const MapLocationRequested());
      await fixed;
      expect(renderer.calls, isEmpty);
      bloc.add(const MapStyleLoaded());
    },
    verify: (_) => expect(
      renderer.calls,
      containsAllInOrder(['location', 'focus-location']),
    ),
  );

  blocTest<MapBloc, MapState>(
    'a feature tap supplies popup attributes and a blank tap clears them',
    build: createBloc,
    act: (bloc) async {
      final loaded = bloc.stream.firstWhere((state) => state.placeCount == 1);
      bloc.add(const MapStyleLoaded());
      bloc.add(const MapLayerRequested());
      await loaded;
      final selected = bloc.stream.firstWhere(
        (state) => state.selected != null,
      );
      bloc.add(const MapTapped(Point(20, 20)));
      final state = await selected;
      expect(state.selected!.name, 'Museum');
      expect(state.selected!.address, 'Jalan Museum');
      renderer.picked = null;
      bloc.add(const MapTapped(Point(100, 100)));
    },
    verify: (bloc) => expect(bloc.state.selected, isNull),
  );

  blocTest<MapBloc, MapState>(
    'failed data loading supports a successful retry',
    setUp: () =>
        maps.response = () async =>
            const FailureResult(Failure(FailureKind.network, 'offline')),
    build: createBloc,
    act: (bloc) async {
      final failed = bloc.stream.firstWhere(
        (state) => state.layerError != null,
      );
      bloc.add(const MapLayerRequested());
      await failed;
      maps.response = () async => Success(layer);
      bloc.add(const MapLayerRequested());
    },
    wait: const Duration(milliseconds: 20),
    verify: (bloc) {
      expect(bloc.state.placeCount, 1);
      expect(bloc.state.layerError, isNull);
    },
  );

  test(
    'a superseded layer request cannot overwrite the latest response',
    () async {
      final old = Completer<Result<MapLayer>>();
      maps.response = () => old.future;
      final bloc = createBloc();
      addTearDown(bloc.close);
      final started = bloc.stream.first;
      bloc.add(const MapLayerRequested());
      await started;
      maps.response = () async => Success(layer);
      final loaded = bloc.stream.firstWhere((state) => state.placeCount == 1);
      bloc.add(const MapLayerRequested());
      await loaded;
      old.complete(Success(MapLayer(name: 'Stale', places: [])));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.layerName, 'Jogja');
    },
  );

  blocTest<MapBloc, MapState>(
    'style reload restores the layer and user marker',
    build: createBloc,
    act: (bloc) async {
      final ready = bloc.stream.firstWhere(
        (state) => state.placeCount == 1 && state.locationMessage != null,
      );
      bloc.add(const MapStyleLoaded());
      bloc.add(const MapLayerRequested());
      bloc.add(const MapLocationRequested(focus: false));
      await ready;
      final reloading = bloc.stream.firstWhere((state) => !state.styleReady);
      bloc.add(const MapStyleReloadRequested());
      await reloading;
      bloc.add(const MapStyleLoaded());
    },
    verify: (bloc) {
      expect(bloc.state.styleReady, isTrue);
      expect(
        renderer.calls,
        containsAllInOrder(['reload', 'layer:Jogja', 'location', 'fit']),
      );
    },
  );

  blocTest<MapBloc, MapState>(
    'GPS service errors direct the user to device location settings',
    setUp: () => locations.result = const FailureResult(
      Failure(FailureKind.serviceDisabled, 'GPS disabled'),
    ),
    build: createBloc,
    act: (bloc) async {
      final failed = bloc.stream.firstWhere(
        (state) => state.locationAction == LocationAction.deviceSettings,
      );
      bloc.add(const MapLocationRequested());
      await failed;
      bloc.add(const MapLocationSettingsRequested());
    },
    verify: (bloc) {
      expect(locations.opened, LocationSettingsTarget.device);
      expect(bloc.state.locationAction, LocationAction.locate);
    },
  );
}
