import 'dart:async';
import 'dart:math';

import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_presentation/src/map/canvas/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/canvas/models/map_scene.dart';
import 'package:map_presentation/src/map/models/map_content.dart';
import 'package:map_presentation/src/map/rendering/map_renderer.dart';
import 'package:map_presentation/src/map/rendering/maplibre_renderer.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mocktail/mocktail.dart';

import 'support/map_fixtures.dart';
import 'support/native_map_harness.dart';

MapScene sceneAt(double latitude) => MapScene(
  focus: MapCameraFocus.userLocation,
  content: MapContent(
    layer: sampleLayer,
    location: LocationFix(
      point: GeoPoint(latitude: latitude, longitude: 106.8),
      accuracyMeters: 12,
    ),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MapLibreRenderer renderer;
  late NativeMapHarness native;
  late List<MapRenderStatus> statuses;

  setUpAll(() {
    registerFallbackValue(const CircleLayerProperties());
    registerFallbackValue(Rect.zero);
    registerFallbackValue(CameraUpdate.zoomBy(1));
    registerFallbackValue(const SymbolLayerProperties());
    registerFallbackValue(Uint8List(0));
  });
  setUp(() async {
    renderer = MapLibreRenderer();
    native = NativeMapHarness();
    statuses = [];
    final subscription = renderer.statuses.listen(statuses.add);
    renderer.attach(native.controller);
    addTearDown(() async {
      await renderer.close();
      await subscription.cancel();
    });
    renderer.render(sceneAt(-6.2));
    renderer.styleLoaded();
    await Future<void>.delayed(Duration.zero);
    expect(statuses.last, MapRenderStatus.ready);
    native.operations.clear();
    native.cameraMoves.clear();
  });

  test('pan during a GPS write prevents the obsolete follow command', () async {
    final gate = Completer<void>();
    native.onWrite = (_, _) => gate.future;
    final moved = sceneAt(-6.21);
    renderer.render(moved);
    await Future<void>.delayed(Duration.zero);
    expect(native.operations, ['user-location']);
    renderer.render(moved.copyWith(focus: MapCameraFocus.free));
    gate.complete();
    await Future<void>.delayed(Duration.zero);
    expect(native.cameraMoves, isEmpty);
    expect(native.operations, ['user-location']);
  });

  test(
    'GPS bursts retain the in-flight write and newest position only',
    () async {
      final gate = Completer<void>();
      native.onWrite = (_, _) => gate.future;
      renderer.render(sceneAt(-6.201));
      await Future<void>.delayed(Duration.zero);
      for (var i = 2; i <= 12; i++) {
        renderer.render(sceneAt(-6.2 - i / 1000));
      }
      // Explicit zoom must survive coalescing and run before the next draw.
      renderer.zoomBy(1);
      gate.complete();
      await Future<void>.delayed(Duration.zero);
      expect(native.operations, [
        'user-location',
        'camera',
        'camera',
        'user-location',
      ]);
      expect(native.cameraMoves, [
        [
          'newLatLng',
          [closeTo(-6.212, 1e-9), closeTo(106.8, 1e-9)],
        ],
        ['zoomBy', 1.0],
      ]);
      final feature =
          (native.sources['user-location']!['features'] as List).single as Map;
      expect((feature['geometry'] as Map)['coordinates'], [
        106.8,
        closeTo(-6.212, 1e-9),
      ]);
    },
  );

  test(
    'camera keeps following when every write receives a newer fix',
    () async {
      var arrivals = 0;
      native.onWrite = (id, _) async {
        if (id == 'user-location' && arrivals < 5) {
          arrivals++;
          renderer.render(sceneAt(-6.21 - arrivals / 1000));
        }
      };
      renderer.render(sceneAt(-6.21));
      await Future<void>.delayed(Duration.zero);
      expect(native.cameraMoves.length, greaterThan(1));
      expect(native.cameraMoves.last, [
        'newLatLng',
        [closeTo(-6.215, 1e-9), closeTo(106.8, 1e-9)],
      ]);
      expect(statuses.last, MapRenderStatus.ready);
    },
  );

  test(
    'a failed pick followed by a heading update preserves sources and zoom',
    () async {
      native.onQuery = () async =>
          throw PlatformException(code: 'query-failed');
      expect(
        await renderer.placeAt(const Point(10, 20)),
        isA<FailureResult<String?>>(),
      );
      final scene = sceneAt(-6.2);
      renderer.render(
        scene.copyWith(
          content: scene.content.copyWith(
            location: LocationFix(
              point: scene.content.location!.point,
              accuracyMeters: 12,
              bearing: const LocationBearing(
                degrees: 90,
                source: LocationBearingSource.compass,
              ),
            ),
          ),
        ),
      );
      native.onQuery = null;
      await renderer.placeAt(const Point(10, 20));
      expect(native.operations, ['query', 'user-location', 'query']);
      expect(native.cameraMoves, isEmpty);
      expect(statuses.last, MapRenderStatus.ready);
    },
  );

  test(
    'camera failure retries without rewriting confirmed source content',
    () async {
      native.onCamera = () async =>
          throw PlatformException(code: 'camera-failed');
      final moved = sceneAt(-6.21);
      renderer.render(moved);
      await Future<void>.delayed(Duration.zero);
      expect(statuses.last, MapRenderStatus.renderingFailure);
      native.operations.clear();
      native.onCamera = null;
      renderer.render(moved);
      await Future<void>.delayed(Duration.zero);
      expect(native.operations, ['camera']);
      expect(native.cameraMoves.last, [
        'newLatLng',
        [closeTo(-6.21, 1e-9), closeTo(106.8, 1e-9)],
      ]);
      expect(statuses.last, MapRenderStatus.ready);
    },
  );

  test('style reload cancels the rest of an in-flight draw', () async {
    final gate = Completer<void>();
    native.onWrite = (_, _) => gate.future;
    renderer.render(sceneAt(-6.21));
    await Future<void>.delayed(Duration.zero);
    renderer.reloadStyle();
    renderer.render(sceneAt(-6.22));
    gate.complete();
    await Future<void>.delayed(Duration.zero);
    expect(native.operations, ['user-location', 'reload']);
    expect(native.cameraMoves, isEmpty);
    renderer.styleLoaded();
    await Future<void>.delayed(Duration.zero);
    expect(native.cameraMoves.single, [
      'newLatLngZoom',
      [closeTo(-6.22, 1e-9), closeTo(106.8, 1e-9)],
      15.0,
    ]);
    expect(statuses.last, MapRenderStatus.ready);
  });

  test(
    'a native style replacement restores sources without an explicit reload',
    () async {
      native.sources.clear();
      native.layers.clear();
      renderer.styleLoaded();
      await Future<void>.delayed(Duration.zero);
      expect(native.operations, ['mapid-places', 'user-location', 'camera']);
      expect(statuses.last, MapRenderStatus.ready);
    },
  );
}
