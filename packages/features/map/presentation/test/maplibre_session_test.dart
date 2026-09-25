import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_presentation/src/map/models/map_scene.dart';
import 'package:map_presentation/src/map/rendering/map_renderer.dart';
import 'package:map_presentation/src/map/rendering/maplibre_session.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mocktail/mocktail.dart';

import 'support/native_map_harness.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const CircleLayerProperties());
    registerFallbackValue(const SymbolLayerProperties());
    registerFallbackValue(CameraUpdate.zoomBy(1));
    registerFallbackValue(Rect.zero);
    registerFallbackValue(Uint8List(0));
  });

  test(
    'style timeout recovers and successful reload cancels its timer',
    () => fakeAsync((clock) {
      final session = MapLibreSession(
        NativeMapHarness().controller,
        styleUrl: "test-style",
      );
      final statuses = <MapRenderStatus>[];
      final subscription = session.statuses.listen(statuses.add);
      clock.flushMicrotasks();
      clock.elapse(const Duration(seconds: 26));
      expect(statuses.last, MapRenderStatus.styleTimeout);
      session.reloadStyle();
      clock.flushMicrotasks();
      expect(statuses.last, MapRenderStatus.loadingStyle);
      session.styleLoaded(const MapScene());
      clock.flushMicrotasks();
      expect(statuses.last, MapRenderStatus.ready);
      clock.elapse(const Duration(seconds: 26));
      expect(statuses.last, MapRenderStatus.ready);
      var closed = false;
      session.close().then((_) => closed = true);
      clock.flushMicrotasks();
      expect(closed, isTrue);
      subscription.cancel();
      expect(clock.pendingTimers, isEmpty);
    }),
  );

  test(
    'close cancels a pending style timeout',
    () => fakeAsync((clock) {
      final session = MapLibreSession(
        NativeMapHarness().controller,
        styleUrl: "test-style",
      );
      final statuses = <MapRenderStatus>[];
      final subscription = session.statuses.listen(statuses.add);
      clock.flushMicrotasks();
      var closed = false;
      session.close().then((_) => closed = true);
      clock.flushMicrotasks();
      expect(closed, isTrue);
      expect(clock.pendingTimers, isEmpty);
      clock.elapse(const Duration(seconds: 26));
      expect(statuses, [MapRenderStatus.loadingStyle]);
      subscription.cancel();
    }),
  );
}
