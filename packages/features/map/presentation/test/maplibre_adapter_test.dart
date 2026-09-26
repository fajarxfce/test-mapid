import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/canvas/maplibre/maplibre_adapter.dart';
import 'package:map_presentation/src/map/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/models/map_canvas_status.dart';

import 'support/annotation_map_harness.dart';
import 'support/map_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(AnnotationMapHarness.registerFallbacks);
  late AnnotationMapHarness native;
  late MapLibreAdapter adapter;
  late List<MapCanvasStatus> statuses;
  late List<String?> selections;
  setUp(() {
    native = AnnotationMapHarness();
    adapter = MapLibreAdapter();
    statuses = [];
    selections = [];
    final statusSubscription = adapter.statuses.listen(statuses.add);
    final selectionSubscription = adapter.selections.listen(selections.add);
    addTearDown(() async {
      await adapter.close();
      await statusSubscription.cancel();
      await selectionSubscription.cancel();
    });
  });
  Future<void> settle() => Future<void>.delayed(Duration.zero);
  Future<void> ready() async {
    adapter.showPlaces(sampleLayer);
    adapter.updateLocation(sampleLocation);
    adapter.attach(native.controller);
    adapter.styleLoaded();
    await settle();
    expect(statuses.last, MapCanvasStatus.ready);
    native.operations.clear();
    native.cameraMoves.clear();
  }

  test('style readiness installs retained data and duplicate inputs do no native work', () async {
    adapter.showPlaces(sampleLayer);
    adapter.attach(native.controller);
    adapter.updateLocation(sampleLocation);
    await settle();
    expect(native.operations, isEmpty);
    adapter.styleLoaded();
    await settle();
    expect(native.operations, ['addPlaces', 'addLocation', 'camera']);
    native.operations.clear();
    adapter.showPlaces(
      MapLayer(name: sampleLayer.name, places: [copySamplePlace()]),
    );
    adapter.updateLocation(sampleLocation);
    await settle();
    expect(native.operations, isEmpty);
  });

  test(
    'native annotation callbacks select only current tourism markers',
    () async {
      await ready();
      final place = native.circles.first;
      native.onCircleTapped.call(place);
      native.onCircleTapped.call(native.circles.last);
      adapter.backgroundTapped();
      await settle();
      expect(selections, [samplePlace.id, null]);
      adapter.showPlaces(MapLayer(name: 'Empty', places: []));
      await settle();
      native.onCircleTapped.call(place);
      await settle();
      expect(selections, [samplePlace.id, null]);
    },
  );

  test('a blocked location write coalesces twelve fixes and a pan supersedes follow', () async {
    await ready();
    adapter.focus(MapCameraFocus.userLocation);
    await settle();
    native.operations.clear();
    final pending = Completer<void>();
    native.onWrite = (operation) =>
        operation == 'updateLocation' ? pending.future : Future.value();
    adapter.updateLocation(
      const LocationFix(
        point: GeoPoint(latitude: -6.21, longitude: 106.8),
        accuracyMeters: 5,
      ),
    );
    await settle();
    for (var i = 0; i < 12; i++) {
      adapter.updateLocation(
        LocationFix(
          point: GeoPoint(latitude: -6.22 - i / 100, longitude: 106.8),
          accuracyMeters: 5,
        ),
      );
    }
    adapter.focus(MapCameraFocus.free);
    adapter.zoomBy(1);
    pending.complete();
    await settle();
    expect(native.operations, ['updateLocation', 'camera', 'updateLocation']);
    expect(native.cameraMoves.last, ['zoomBy', 1.0]);
  });

  test('changing focus during a source write frames once, and repeating still works', () async {
    await ready();
    final pending = Completer<void>();
    native.onWrite = (operation) =>
        operation == 'updateLocation' ? pending.future : Future.value();
    adapter.updateLocation(
      const LocationFix(
        point: GeoPoint(latitude: -6.21, longitude: 106.8),
        accuracyMeters: 5,
      ),
    );
    await settle();
    adapter.focus(MapCameraFocus.userLocation);
    pending.complete();
    await settle();
    expect(native.cameraMoves, hasLength(1));
    adapter.focus(MapCameraFocus.userLocation);
    await settle();
    expect(native.cameraMoves, hasLength(2));
  });

  test('a failed annotation update retries the desired data without duplicate markers', () async {
    await ready();
    final updated = MapLayer(
      name: 'Updated',
      places: [copySamplePlace(name: 'Updated')],
    );
    native.onWrite = (operation) async {
      if (operation == 'addPlaces') throw PlatformException(code: 'failed');
    };
    adapter.showPlaces(updated);
    await settle();
    expect(statuses.last, MapCanvasStatus.renderingFailure);
    native.onWrite = null;
    adapter.showPlaces(updated);
    await settle();
    expect(statuses.last, MapCanvasStatus.ready);
    expect(
      native.circles.where((circle) => circle.data?['place_id'] != null),
      hasLength(1),
    );
  });

  test(
    'style reload restores annotations and preserves the current camera mode',
    () async {
      await ready();
      adapter.focus(MapCameraFocus.free);
      adapter.retry();
      await settle();
      expect(statuses.last, MapCanvasStatus.loadingStyle);
      expect(native.circles, isEmpty);
      adapter.styleLoaded();
      await settle();
      expect(statuses.last, MapCanvasStatus.ready);
      expect(native.circles, hasLength(2));
      expect(native.cameraMoves, isEmpty);
    },
  );

  test(
    'controller replacement proceeds while old native I/O remains blocked',
    () async {
      await ready();
      final pending = Completer<void>();
      native.onWrite = (_) => pending.future;
      adapter.updateLocation(
        const LocationFix(
          point: GeoPoint(latitude: -6.21, longitude: 106.8),
          accuracyMeters: 5,
        ),
      );
      await settle();
      final replacement = AnnotationMapHarness();
      adapter.attach(replacement.controller);
      adapter.styleLoaded();
      await settle();
      expect(statuses.last, MapCanvasStatus.ready);
      expect(replacement.circles, hasLength(2));
      final count = statuses.length;
      pending.completeError(PlatformException(code: 'old-controller'));
      await settle();
      expect(statuses, hasLength(count));
      expect(native.operations, ['updateLocation']);
    },
  );

  test('close during I/O prevents later commands and status or selection emissions', () async {
    await ready();
    final pending = Completer<void>();
    native.onWrite = (_) => pending.future;
    adapter.showPlaces(MapLayer(name: 'Updated', places: [samplePlace]));
    adapter.zoomBy(1);
    await settle();
    await adapter.close();
    final count = statuses.length;
    pending.complete();
    await settle();
    native.onCircleTapped.call(native.circles.single);
    expect(native.operations, ['removePlaces']);
    expect(statuses, hasLength(count));
    expect(selections, isEmpty);
  });

  test('creation and style deadlines recover and all timers are released', () {
    fakeAsync((clock) {
      final canvas = MapLibreAdapter();
      final events = <MapCanvasStatus>[];
      final subscription = canvas.statuses.listen(events.add);
      clock.elapse(const Duration(seconds: 26));
      expect(events.last, MapCanvasStatus.creationTimeout);
      canvas.attach(native.controller);
      canvas.styleLoaded();
      clock.flushMicrotasks();
      expect(events.last, MapCanvasStatus.creationTimeout);
      canvas.retry();
      canvas.attach(native.controller);
      clock.elapse(const Duration(seconds: 26));
      expect(events.last, MapCanvasStatus.styleTimeout);
      canvas.retry();
      clock.flushMicrotasks();
      canvas.styleLoaded();
      clock.flushMicrotasks();
      expect(events.last, MapCanvasStatus.ready);
      expect(clock.pendingTimers, isEmpty);
      canvas.close();
      clock.flushMicrotasks();
      subscription.cancel();
    });
  });
}
