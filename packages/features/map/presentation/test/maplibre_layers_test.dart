import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/rendering/maplibre_layers.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mocktail/mocktail.dart';

import 'support/map_fixtures.dart';
import 'support/mock_map_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TestMapController controller;
  late MapLibreLayers layers;
  late Set<String> sourceIds;
  late Set<String> layerIds;
  late List<Map<String, dynamic>> writes;
  setUpAll(() {
    registerFallbackValue(const CircleLayerProperties());
    registerFallbackValue(Rect.zero);
    registerFallbackValue(const SymbolLayerProperties());
    registerFallbackValue(Uint8List(0));
  });
  setUp(() {
    controller = TestMapController();
    when(() => controller.isDisposed).thenReturn(false);
    layers = MapLibreLayers(controller);
    sourceIds = {};
    layerIds = {};
    writes = [];
    when(controller.getSourceIds).thenAnswer((_) async => sourceIds.toList());
    when(() => controller.addImage(any(), any())).thenAnswer((_) async {});
    when(
      () => controller.addSymbolLayer(
        any(),
        any(),
        any(),
        filter: any<dynamic>(named: 'filter'),
        enableInteraction: false,
      ),
    ).thenAnswer((call) async {
      layerIds.add(call.positionalArguments[1] as String);
    });
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

  test('encodes feature IDs and GeoJSON longitude before latitude', () async {
    await layers.showPlaces(sampleLayer);
    final data = writes.last;
    final feature = (data['features'] as List).single as Map;
    expect(feature['id'], samplePlace.id);
    expect(feature['properties'], {'place_id': samplePlace.id});
    expect((feature['geometry'] as Map)['coordinates'], [110.36, -7.8]);
    await layers.showLocation(sampleLocation);
    final location = (writes.last['features'] as List).single as Map;
    expect((location['geometry'] as Map)['coordinates'], [106.8, -6.2]);
  });

  test('heading uses a map-aligned symbol and disappears when bearing is unavailable', () async {
    final location = LocationFix(
      point: sampleLocation.point,
      accuracyMeters: 12,
      bearing: const LocationBearing(
        degrees: 90,
        source: LocationBearingSource.compass,
      ),
    );
    await layers.showLocation(location);
    await layers.showLocation(location);
    expect(layerIds, contains('user-location-heading'));
    final imageBytes =
        verify(() => controller.addImage('user-heading-arrow', captureAny()))
                .captured
                .single
            as Uint8List;
    final codec = await ui.instantiateImageCodec(imageBytes);
    final image = (await codec.getNextFrame()).image;
    final ratio =
        ui.PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1;
    expect(image.width, (64 * ratio).ceil());
    expect(image.height, (64 * ratio).ceil());
    final pixels = (await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    ))!;
    final arrowCenter =
        ((12 * ratio).floor() * image.width + (32 * ratio).floor()) * 4;
    final belowArrow =
        ((40 * ratio).floor() * image.width + (32 * ratio).floor()) * 4;
    expect(pixels.getUint8(arrowCenter + 3), 255);
    expect(pixels.getUint8(belowArrow + 3), 0);
    image.dispose();
    codec.dispose();
    final properties =
        verify(
              () => controller.addSymbolLayer(
                'user-location',
                'user-location-heading',
                captureAny(),
                filter: any<dynamic>(named: 'filter'),
                enableInteraction: false,
              ),
            ).captured.single
            as SymbolLayerProperties;
    expect(properties.iconRotationAlignment, 'map');
    expect(properties.iconRotate, ['get', 'bearing']);
    final feature = (writes.last['features'] as List).single as Map;
    expect((feature['properties'] as Map)['bearing'], 90);
    await layers.showLocation(sampleLocation);
    final unavailable = (writes.last['features'] as List).single as Map;
    expect((unavailable['properties'] as Map)['bearing'], isNull);
    await layers.showLocation(null);
    expect(writes.last['features'], isEmpty);
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
      expect(sourceIds, contains('mapid-places'));
      expect(layerIds, isEmpty);
      await layers.showPlaces(sampleLayer);
      expect(layerIds, contains('mapid-place-points'));
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
      verify(() => controller.setGeoJsonSource('mapid-places', any()))
          .called(1);
    },
  );

  test('places and location have independent source and layer IDs', () async {
    await layers.showPlaces(sampleLayer);
    await layers.showLocation(sampleLocation);
    expect(sourceIds, {'mapid-places', 'user-location'});
    expect(layerIds, {'mapid-place-points', 'user-location-point'});
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
            expect(call.positionalArguments[1], ['mapid-place-points']);
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
