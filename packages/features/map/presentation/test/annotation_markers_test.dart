import 'dart:async';
import 'dart:ui' as ui;

import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/canvas/maplibre/location_marker.dart';
import 'package:map_presentation/src/map/canvas/maplibre/tourism_markers.dart';

import 'support/annotation_map_harness.dart';
import 'support/map_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(AnnotationMapHarness.registerFallbacks);
  late AnnotationMapHarness native;
  late TourismMarkers places;
  late LocationMarker location;
  setUp(() {
    native = AnnotationMapHarness();
    places = TourismMarkers(native.controller);
    location = LocationMarker(native.controller);
  });
  LocationFix pointing(double degrees) => LocationFix(
    point: sampleLocation.point,
    accuracyMeters: 12,
    bearing: LocationBearing(
      degrees: degrees,
      source: LocationBearingSource.compass,
    ),
  );

  test('tourism annotations keep place IDs and equal refresh preserves their identity', () async {
    await places.show(sampleLayer);
    final marker = native.circles.single;
    expect(places.placeId(marker), samplePlace.id);
    expect(marker.options.geometry!.latitude, samplePlace.point.latitude);
    await places.show(
      MapLayer(name: sampleLayer.name, places: [copySamplePlace()]),
    );
    expect(native.circles.single, same(marker));
    expect(native.operations, ['addPlaces']);
    await places.show(MapLayer(name: 'Empty', places: []));
    expect(native.circles, isEmpty);
    expect(places.placeId(marker), isNull);
  });

  test(
    'retry removes SDK annotations left behind by a rejected native add',
    () async {
      native.onWrite = (operation) async {
        if (operation == 'addPlaces') throw PlatformException(code: 'failed');
      };
      await expectLater(
        places.show(sampleLayer),
        throwsA(isA<PlatformException>()),
      );
      expect(native.circles, hasLength(1));
      native.onWrite = null;
      await places.show(sampleLayer);
      expect(native.circles, hasLength(1));
      expect(native.operations, ['addPlaces', 'removePlaces', 'addPlaces']);
    },
  );

  test('clearing after a failed add removes stale annotations without touching GPS', () async {
    await location.show(sampleLocation);
    native.onWrite = (operation) async {
      if (operation == 'addPlaces') throw PlatformException(code: 'failed');
    };
    await expectLater(
      places.show(sampleLayer),
      throwsA(isA<PlatformException>()),
    );
    native.onWrite = null;
    await places.show(null);
    expect(native.circles.single.data?['role'], 'user-location');
  });

  test(
    'compass updates only the heading annotation and preserves tourism markers',
    () async {
      await places.show(sampleLayer);
      await location.show(pointing(90));
      final marker = native.circles.first;
      native.operations.clear();
      await location.show(pointing(120));
      expect(native.operations, ['updateHeading']);
      expect(native.circles.first, same(marker));
      expect(native.symbols.single.options.iconRotate, 120);
      expect(
        native.headingStyle!.iconImage,
        [
          'image',
          ['get', 'iconImage'],
        ],
        reason: 'Android needs runtime icon IDs resolved as images for layout.',
      );
      expect(native.headingStyle!.iconRotate, [
        'to-number',
        ['get', 'iconRotate'],
      ], reason: 'Untyped native layout values left the arrow pointing north.');
      expect(native.headingStyle!.iconSize, [
        'to-number',
        ['get', 'iconSize'],
      ], reason: 'The native arrow must use its configured annotation scale.');
      expect(native.headingStyle!.iconRotationAlignment, 'map');
      expect(native.headingStyle!.iconIgnorePlacement, isTrue);
      final codec = await ui.instantiateImageCodec(native.image!);
      final image = (await codec.getNextFrame()).image;
      final ratio =
          ui.PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1;
      expect(image.width, (64 * ratio).ceil());
      expect(image.height, image.width);
      image.dispose();
      codec.dispose();
      await location.show(sampleLocation);
      expect(native.symbols, isEmpty);
      await location.show(null);
      expect(native.circles.single, same(marker));
    },
  );

  test(
    'failed heading update retries without rewriting the confirmed position',
    () async {
      await location.show(pointing(90));
      native.operations.clear();
      native.onWrite = (operation) async {
        if (operation == 'updateHeading') {
          throw PlatformException(code: 'failed');
        }
      };
      await expectLater(
        location.show(pointing(120)),
        throwsA(isA<PlatformException>()),
      );
      native.onWrite = null;
      await location.show(pointing(90));
      expect(native.operations, ['updateHeading', 'updateHeading']);
      expect(native.symbols.single.options.iconRotate, 90);
    },
  );

  test(
    'closing during location acquisition prevents later heading operations',
    () async {
      final pending = Completer<void>();
      native.onWrite = (_) => pending.future;
      final showing = location.show(pointing(90));
      location.close();
      pending.complete();
      await showing;
      expect(native.operations, ['addLocation']);
    },
  );
}
