import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';
import 'package:map_presentation/src/map/models/location_action.dart';

import 'support/fake_repositories.dart';
import 'support/map_fixtures.dart';

void main() {
  late FakeMapRepository maps;
  late FakeLocationRepository locations;
  MapBloc createBloc() => MapBloc(
    LoadMapLayer(maps),
    GetCurrentLocation(locations),
    OpenLocationSettings(locations),
  );
  setUp(() {
    maps = FakeMapRepository();
    locations = FakeLocationRepository();
  });

  blocTest<MapBloc, MapState>(
    'loads layer data without creating a native map',
    build: createBloc,
    act: (bloc) => bloc.add(const MapLayerRequested()),
    verify: (bloc) {
      expect(bloc.state.layer, same(sampleLayer));
      expect(bloc.state.content.layer, same(sampleLayer));
      expect(bloc.state.placeCount, 1);
      expect(bloc.state.loadingLayer, isFalse);
    },
  );

  blocTest<MapBloc, MapState>(
    'location denial does not prevent layer loading',
    setUp: () => locations.response = () async =>
        const FailureResult(Failure(FailureKind.permissionDenied, 'internal')),
    build: createBloc,
    act: (bloc) {
      bloc.add(const MapLayerRequested());
      bloc.add(const MapLocationRequested());
    },
    verify: (bloc) {
      expect(bloc.state.placeCount, 1);
      expect(bloc.state.locationFailure?.kind, FailureKind.permissionDenied);
      expect(
        bloc.state.locationMessage,
        contains('Peta wisata tetap bisa digunakan'),
      );
      expect(bloc.state.locationMessage, isNot(contains('internal')));
    },
  );

  test('a superseded request cannot overwrite newer layer data', () async {
    final old = Completer<Result<MapLayer>>();
    final started = Completer<void>();
    maps.response = () {
      started.complete();
      return old.future;
    };
    final bloc = createBloc();
    addTearDown(bloc.close);
    bloc.add(const MapLayerRequested());
    await started.future;
    maps.response = () async => Success(sampleLayer);
    final loaded = bloc.stream.firstWhere((state) => state.layer != null);
    bloc.add(const MapLayerRequested());
    await loaded;
    old.complete(Success(MapLayer(name: 'Stale', places: [])));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.layer, same(sampleLayer));
  });

  test(
    'a failed refresh preserves the visible layer and can be retried',
    () async {
      final bloc = createBloc();
      addTearDown(bloc.close);
      var settled = bloc.stream.firstWhere((state) => state.layer != null);
      bloc.add(const MapLayerRequested());
      await settled;
      maps.response = () async =>
          const FailureResult(Failure(FailureKind.network, 'network'));
      settled = bloc.stream.firstWhere((state) => state.layerFailure != null);
      bloc.add(const MapLayerRequested());
      await settled;
      expect(bloc.state.layer, same(sampleLayer));
      maps.response = () async => Success(sampleLayer);
      settled = bloc.stream.firstWhere(
        (state) => !state.loadingLayer && state.layerFailure == null,
      );
      bloc.add(const MapLayerRequested());
      await settled;
      expect(bloc.state.layerError, isNull);
    },
  );

  test('repeated location requests share one in-flight operation', () async {
    final pending = Completer<Result<LocationFix>>();
    locations.response = () => pending.future;
    final bloc = createBloc();
    addTearDown(bloc.close);
    final started = bloc.stream.firstWhere((state) => state.locating);
    bloc.add(const MapLocationRequested());
    await started;
    bloc.add(const MapLocationRequested());
    await Future<void>.delayed(Duration.zero);
    expect(locations.calls, 1);
    final found = bloc.stream.firstWhere((state) => state.location != null);
    pending.complete(const Success(sampleLocation));
    await found;
    expect(bloc.state.locationMessage, contains('12 m'));
  });

  test(
    'the location button completes GPS acquisition and releases the Bloc',
    () async {
      final bloc = createBloc();
      final found = bloc.stream.firstWhere((state) => state.location != null);
      bloc.add(const MapLocationActionRequested());
      await found;
      expect(locations.calls, 1);
      await bloc.close().timeout(const Duration(seconds: 2));
      expect(bloc.isClosed, isTrue);
    },
  );

  for (final entry in {
    FailureKind.serviceDisabled: LocationSettingsTarget.device,
    FailureKind.permissionPermanentlyDenied: LocationSettingsTarget.application,
  }.entries) {
    blocTest<MapBloc, MapState>(
      'opens the right settings for ${entry.key}',
      setUp: () =>
          locations.response = () async =>
              FailureResult(Failure(entry.key, 'internal')),
      build: createBloc,
      act: (bloc) async {
        final failed = bloc.stream.firstWhere(
          (state) => state.locationFailure != null,
        );
        bloc.add(const MapLocationRequested());
        await failed;
        bloc.add(const MapLocationActionRequested());
      },
      verify: (bloc) {
        expect(locations.opened, entry.value);
        expect(bloc.state.locationAction, LocationAction.locate);
        expect(bloc.state.settingsMessage, isNotNull);
      },
    );
  }

  test(
    'closing while data is pending does not publish a late result',
    () async {
      final pending = Completer<Result<MapLayer>>();
      final started = Completer<void>();
      maps.response = () {
        started.complete();
        return pending.future;
      };
      final bloc = createBloc();
      bloc.add(const MapLayerRequested());
      await started.future;
      await bloc.close();
      pending.complete(Success(sampleLayer));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.layer, isNull);
    },
  );
}
