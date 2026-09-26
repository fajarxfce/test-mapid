import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_presentation/src/map/canvas/maplibre/map_camera.dart';
import 'package:map_presentation/src/map/models/map_camera_focus.dart';

import 'support/annotation_map_harness.dart';
import 'support/map_fixtures.dart';

void main() {
  setUpAll(AnnotationMapHarness.registerFallbacks);
  late AnnotationMapHarness native;
  late MapCamera camera;
  setUp(() {
    native = AnnotationMapHarness();
    camera = MapCamera()..attach(native.controller);
  });

  test(
    'cancelled framing retries while accepted framing is idempotent',
    () async {
      native.cameraOutcome = false;
      await camera.update(sampleLayer, sampleLocation);
      native.cameraOutcome = true;
      await camera.update(sampleLayer, sampleLocation);
      await camera.update(sampleLayer, sampleLocation);
      expect(native.cameraMoves, hasLength(2));
    },
  );

  test('null iOS acknowledgment confirms framing', () async {
    native.cameraOutcome = null;
    await camera.update(sampleLayer, null);
    await camera.update(sampleLayer, null);
    expect(native.cameraMoves, hasLength(1));
  });

  test(
    'follow preserves zoom, ignores heading-only updates and stops on pan',
    () async {
      camera.requestFocus(MapCameraFocus.userLocation);
      await camera.update(sampleLayer, sampleLocation);
      await camera.update(
        sampleLayer,
        LocationFix(
          point: sampleLocation.point,
          accuracyMeters: 3,
          bearing: const LocationBearing(
            degrees: 90,
            source: LocationBearingSource.compass,
          ),
        ),
      );
      expect(native.operations, ['camera']);
      const moved = LocationFix(
        point: GeoPoint(latitude: -6.21, longitude: 106.8),
        accuracyMeters: 3,
      );
      await camera.update(sampleLayer, moved);
      expect(native.operations, ['camera', 'ease']);
      expect((native.cameraMoves.last as List<Object?>)[0], 'newLatLng');
      camera.requestFocus(MapCameraFocus.free);
      await camera.update(sampleLayer, sampleLocation);
      expect(native.operations, ['camera', 'ease']);
    },
  );

  test(
    'queued explicit framing runs once and a newer pan supersedes it',
    () async {
      camera.requestFocus(MapCameraFocus.userLocation, waitForCommand: true);
      await camera.update(sampleLayer, sampleLocation);
      expect(native.cameraMoves, isEmpty);
      await camera.applyFocus(
        MapCameraFocus.userLocation,
        sampleLayer,
        sampleLocation,
      );
      expect(native.cameraMoves, hasLength(1));
      camera.requestFocus(MapCameraFocus.userLocation, waitForCommand: true);
      camera.requestFocus(MapCameraFocus.free);
      await camera.applyFocus(
        MapCameraFocus.userLocation,
        sampleLayer,
        sampleLocation,
      );
      expect(native.cameraMoves, hasLength(1));
    },
  );

  test('focus requested before location exists frames the first fix', () async {
    camera.requestFocus(MapCameraFocus.userLocation);
    await camera.update(sampleLayer, null);
    await camera.update(sampleLayer, sampleLocation);
    expect((native.cameraMoves.single as List<Object?>)[0], 'newLatLngZoom');
  });
  test('cancelled follow invalidates its old center and retries a returning position', () async {
    camera.requestFocus(MapCameraFocus.userLocation);
    await camera.update(sampleLayer, sampleLocation);
    native.cameraOutcome = false;
    await camera.update(
      sampleLayer,
      const LocationFix(
        point: GeoPoint(latitude: -6.21, longitude: 106.8),
        accuracyMeters: 5,
      ),
    );
    native.cameraOutcome = true;
    await camera.update(sampleLayer, sampleLocation);
    expect(native.operations, ['camera', 'ease', 'ease']);
  });
}
