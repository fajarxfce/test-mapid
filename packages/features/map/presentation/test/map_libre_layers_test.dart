import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_geojson_encoder.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_libre_layers.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_style.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mocktail/mocktail.dart';

import 'support/map_fixtures.dart';
import 'support/mock_map_controller.dart';

void main() {
  late TestMapController controller;
  late MapLibreLayers layers;
  late Set<String> sourceIds;
  late Set<String> layerIds;
  late List<Map<String, dynamic>> writes;
  setUpAll(() {
    registerFallbackValue(const CircleLayerProperties());
    registerFallbackValue(Rect.zero);
  });
  setUp(() {
    controller = TestMapController();
    when(() => controller.isDisposed).thenReturn(false);
    layers = MapLibreLayers(controller);
    sourceIds = {};
    layerIds = {};
    writes = [];
    when(controller.getSourceIds).thenAnswer((_) async => sourceIds.toList());
    when(controller.getLayerIds).thenAnswer((_) async => layerIds.toList());
    when(() => controller.addGeoJsonSource(any(), any()))
        .thenAnswer((call) async {
          sourceIds.add(call.positionalArguments[0] as String);
          writes.add(call.positionalArguments[1] as Map<String, dynamic>);
        });
    when(() => controller.setGeoJsonSource(any(), any()))
        .thenAnswer((call) async {
          writes.add(call.positionalArguments[1] as Map<String, dynamic>);
        });
    when(
      () => controller.addCircleLayer(
        any(),
        any(),
        any(),
        enableInteraction: false,
      ),
    ).thenAnswer((call) async {
      expect(sourceIds, contains(call.positionalArguments[0]));
      layerIds.add(call.positionalArguments[1] as String);
    });
  });

  test('encodes feature IDs and GeoJSON longitude before latitude', () {
    final data = placesGeoJson(sampleLayer);
    final feature = (data['features'] as List).single as Map;
    expect(feature['id'], samplePlace.id);
    expect(feature['properties'], {'place_id': samplePlace.id});
    expect((feature['geometry'] as Map)['coordinates'], [110.36, -7.8]);
    final location =
        (locationGeoJson(sampleLocation)['features'] as List).single as Map;
    expect((location['geometry'] as Map)['coordinates'], [106.8, -6.2]);
  });

  test(
    'retries a failed layer creation when its source already exists',
    () async {
      var attempts = 0;
      when(
        () => controller.addCircleLayer(
          any(),
          any(),
          any(),
          enableInteraction: false,
        ),
      ).thenAnswer((call) async {
        if (++attempts == 1) throw PlatformException(code: 'interrupted');
        layerIds.add(call.positionalArguments[1] as String);
      });
      await expectLater(
        layers.showPlaces(sampleLayer),
        throwsA(isA<PlatformException>()),
      );
      expect(sourceIds, contains(MapStyle.placesSource));
      expect(layerIds, isEmpty);
      await layers.showPlaces(sampleLayer);
      expect(layerIds, contains(MapStyle.placesLayer));
      verify(() => controller.addGeoJsonSource(any(), any())).called(1);
      expect(attempts, 2);
    },
  );

  test(
    'refreshes an existing layer in one GeoJSON write and clears empty data',
    () async {
      await layers.showPlaces(sampleLayer);
      await layers.showPlaces(MapLayer(name: 'Empty', places: []));
      expect(writes.last['features'], isEmpty);
      verify(
        () => controller.addCircleLayer(
          any(),
          any(),
          any(),
          enableInteraction: false,
        ),
      ).called(1);
      verify(() => controller.setGeoJsonSource(MapStyle.placesSource, any()))
          .called(1);
    },
  );

  test('places and location have independent source and layer IDs', () async {
    await layers.showPlaces(sampleLayer);
    await layers.showLocation(sampleLocation);
    expect(sourceIds, {MapStyle.placesSource, MapStyle.locationSource});
    expect(layerIds, {MapStyle.placesLayer, MapStyle.locationLayer});
  });

  test(
    'disposal during source lookup prevents subsequent native writes',
    () async {
      final pending = Completer<List<String>>();
      when(controller.getSourceIds).thenAnswer((_) => pending.future);
      final rendering = layers.showPlaces(sampleLayer);
      when(() => controller.isDisposed).thenReturn(true);
      pending.complete([]);
      await rendering;
      verifyNever(() => controller.addGeoJsonSource(any(), any()));
      verifyNever(controller.getLayerIds);
    },
  );

  test(
    'native picking queries only tourism features and ignores malformed hits',
    () async {
      when(() => controller.queryRenderedFeaturesInRect(any(), any(), null))
          .thenAnswer((call) async {
            expect(call.positionalArguments[1], [MapStyle.placesLayer]);
            expect(
              (call.positionalArguments[0] as Rect).center,
              const Offset(100, 200),
            );
            return [
              {'properties': <String, dynamic>{}},
              {
                'properties': {'place_id': 'place-1'},
              },
            ];
          });
      expect(await layers.placeAt(const Point(100, 200)), 'place-1');
    },
  );
}
