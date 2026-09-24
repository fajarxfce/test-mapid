import 'dart:async';
import 'dart:math';

import 'package:core_common/core_common.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/canvas/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/canvas/models/map_scene.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_libre_renderer.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_render_status.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_style.dart';
import 'package:map_presentation/src/map/models/map_content.dart';
import 'package:maplibre_gl/maplibre_gl.dart'
    show CameraUpdate, CircleLayerProperties, SymbolLayerProperties;
import 'package:mocktail/mocktail.dart';

import 'support/map_fixtures.dart';
import 'support/native_map_harness.dart';

void main() {
  late MapLibreRenderer renderer;
  late NativeMapHarness native;
  late List<MapRenderStatus> statuses;
  final scene = MapScene(
    content: MapContent(layer: sampleLayer, location: sampleLocation),
  );
  setUpAll(() {
    registerFallbackValue(const CircleLayerProperties());
    registerFallbackValue(Rect.zero);
    registerFallbackValue(CameraUpdate.zoomBy(1));
    registerFallbackValue(const SymbolLayerProperties());
    registerFallbackValue(Uint8List(0));
  });
  setUp(() {
    renderer = MapLibreRenderer();
    native = NativeMapHarness();
    statuses = [];
  });
  tearDown(() => renderer.close());

  void attach([NativeMapHarness? target]) {
    final subscription = renderer
        .attach((target ?? native).controller)
        .listen(statuses.add);
    addTearDown(subscription.cancel);
  }

  Future<void> settle() => Future<void>.delayed(Duration.zero);
  Future<void> ready([MapScene? initial]) async {
    renderer.render(initial ?? scene);
    attach();
    renderer.styleLoaded();
    await settle();
    expect(statuses.last, MapRenderStatus.ready);
    native.operations.clear();
    native.cameraMoves.clear();
  }

  test(
    'retains the newest scene before creation and waits for style readiness',
    () async {
      renderer.render(MapScene(content: MapContent(layer: sampleLayer)));
      attach();
      renderer.render(scene);
      await settle();
      expect(native.operations, isEmpty);
      expect(statuses, [MapRenderStatus.loadingStyle]);
      renderer.styleLoaded();
      await settle();
      expect(native.operations, [
        MapStyle.placesSource,
        MapStyle.locationSource,
        'camera',
      ]);
      expect(
        native.sources[MapStyle.locationSource]!['features'],
        hasLength(1),
      );
      expect(statuses.last, MapRenderStatus.ready);
    },
  );

  test(
    'unchanged scenes are idempotent and repeated focus still recenters',
    () async {
      await ready();
      renderer.render(scene);
      await settle();
      expect(native.operations, isEmpty);
      renderer.focus(scene);
      renderer.focus(scene);
      await settle();
      expect(native.operations, ['camera', 'camera']);
    },
  );

  test('late GPS respects newer tourism focus without fitting again', () async {
    final places = MapScene(content: MapContent(layer: sampleLayer));
    await ready(places);
    renderer.focus(places.copyWith(focus: MapCameraFocus.userLocation));
    renderer.focus(places);
    renderer.render(scene);
    await settle();
    expect(native.operations, ['camera', MapStyle.locationSource]);
    expect(native.cameraMoves.single, [
      'newLatLngZoom',
      [-7.8, closeTo(110.36, 1e-9)],
      14.0,
    ]);
  });

  test('refresh while GPS is focused only writes tourism data', () async {
    final focused = scene.copyWith(focus: MapCameraFocus.userLocation);
    await ready(focused);
    renderer.render(
      focused.copyWith(
        content: focused.content.copyWith(
          layer: MapLayer(name: 'Reloaded', places: [samplePlace]),
        ),
      ),
    );
    await settle();
    expect(native.operations, [MapStyle.placesSource]);
  });

  test('style replacement restores latest sources and camera intent', () async {
    await ready();
    renderer.reloadStyle();
    renderer.focus(scene.copyWith(focus: MapCameraFocus.userLocation));
    await settle();
    expect(native.operations, ['reload']);
    expect(native.sources, isEmpty);
    renderer.styleLoaded();
    await settle();
    expect(native.operations, [
      'reload',
      MapStyle.placesSource,
      MapStyle.locationSource,
      'camera',
    ]);
    expect(native.layers, {MapStyle.placesLayer, MapStyle.locationLayer});
    expect(native.cameraMoves.single, [
      'newLatLngZoom',
      [-6.2, closeTo(106.8, 1e-9)],
      15.0,
    ]);
    expect(statuses.last, MapRenderStatus.ready);
  });

  test(
    'native source updates complete before queued camera commands',
    () async {
      await ready(const MapScene());
      final pending = Completer<void>();
      native.onWrite = (id, _) async {
        if (id == MapStyle.placesSource) await pending.future;
      };
      renderer.render(scene);
      renderer.zoomBy(1);
      await settle();
      expect(native.operations, [MapStyle.placesSource]);
      pending.complete();
      await settle();
      expect(native.operations, [
        MapStyle.placesSource,
        MapStyle.locationSource,
        'camera',
        'camera',
      ]);
      expect(native.cameraMoves.last, ['zoomBy', 1.0]);
    },
  );

  test('a failed partial render can retry the same desired scene', () async {
    await ready(const MapScene());
    native.onWrite = (id, _) async {
      if (id == MapStyle.locationSource) {
        throw PlatformException(code: 'failed');
      }
    };
    renderer.render(scene);
    await settle();
    expect(statuses.last, MapRenderStatus.renderingFailure);
    native.onWrite = null;
    renderer.render(scene);
    await settle();
    expect(statuses.last, MapRenderStatus.ready);
    expect(native.sources[MapStyle.locationSource]!['features'], hasLength(1));
    expect(native.cameraMoves, hasLength(1));
  });

  test(
    'rolling back after a partial write restores the previous native content',
    () async {
      await ready(const MapScene());
      native.onWrite = (id, _) async {
        if (id == MapStyle.locationSource) {
          throw PlatformException(code: 'failed');
        }
      };
      renderer.render(scene);
      await settle();
      expect(native.sources[MapStyle.placesSource]!['features'], hasLength(1));
      native.onWrite = null;
      renderer.render(const MapScene());
      await settle();
      expect(native.sources[MapStyle.placesSource]!['features'], isEmpty);
      expect(native.sources[MapStyle.locationSource]!['features'], isEmpty);
      expect(statuses.last, MapRenderStatus.ready);
    },
  );

  test(
    'feature query failures return a typed failure and rendering status',
    () async {
      await ready();
      native.onQuery = () async =>
          throw PlatformException(code: 'query-failed');
      final result = await renderer.placeAt(const Point(10, 20));
      await settle();
      expect(
        result,
        isA<FailureResult<String?>>().having(
          (result) => result.failure.kind,
          'kind',
          FailureKind.unexpected,
        ),
      );
      expect(statuses.last, MapRenderStatus.renderingFailure);
    },
  );

  test('querying before style readiness performs no native work', () async {
    attach();
    expect(
      await renderer.placeAt(const Point(10, 20)),
      isA<Success<String?>>().having((result) => result.value, 'value', isNull),
    );
    expect(native.operations, isEmpty);
  });

  test(
    'replacement keeps the scene and cancels a pending old-controller pick',
    () async {
      await ready();
      final pending = Completer<List<dynamic>>();
      native.onQuery = () => pending.future;
      final pick = renderer.placeAt(const Point(10, 20));
      await settle();
      final replacement = NativeMapHarness();
      attach(replacement);
      renderer.styleLoaded();
      await settle();
      pending.complete([
        {
          'properties': {'place_id': 'place-1'},
        },
      ]);
      expect(
        await pick,
        isA<FailureResult<String?>>().having(
          (result) => result.failure.kind,
          'kind',
          FailureKind.cancelled,
        ),
      );
      expect(native.operations, ['query']);
      expect(replacement.operations, [
        MapStyle.placesSource,
        MapStyle.locationSource,
        'camera',
      ]);
    },
  );

  test(
    'close during a native write stops later sources and camera operations',
    () async {
      await ready(const MapScene());
      final pending = Completer<void>();
      native.onWrite = (_, _) => pending.future;
      renderer.render(scene);
      renderer.zoomBy(1);
      await settle();
      await renderer.close();
      final statusCount = statuses.length;
      pending.complete();
      await settle();
      expect(native.operations, [MapStyle.placesSource]);
      expect(statuses, hasLength(statusCount));
    },
  );

  test(
    'a pending native exception after close produces no late status',
    () async {
      await ready(const MapScene());
      final pending = Completer<void>();
      native.onWrite = (_, _) => pending.future;
      renderer.render(scene);
      await settle();
      await renderer.close();
      final statusCount = statuses.length;
      pending.completeError(PlatformException(code: 'disposed'));
      await settle();
      expect(statuses, hasLength(statusCount));
    },
  );

  testWidgets(
    'style timeout recovers and successful reload cancels its timer',
    (tester) async {
      // Attach inside the widget test's clock so the timer is deterministic.
      attach();
      await tester.pump();
      await tester.pump(const Duration(seconds: 26));
      expect(statuses.last, MapRenderStatus.styleTimeout);
      renderer.reloadStyle();
      await tester.pump();
      expect(statuses.last, MapRenderStatus.loadingStyle);
      renderer.styleLoaded();
      await tester.pump();
      expect(statuses.last, MapRenderStatus.ready);
      await tester.pump(const Duration(seconds: 26));
      expect(statuses.last, MapRenderStatus.ready);
      await renderer.close();
    },
  );

  testWidgets('close cancels a pending style timeout', (tester) async {
    attach();
    await tester.pump();
    await renderer.close();
    await tester.pump(const Duration(seconds: 26));
    expect(statuses, [MapRenderStatus.loadingStyle]);
  });
}
