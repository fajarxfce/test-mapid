import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/canvas/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/canvas/models/map_scene.dart';
import 'package:map_presentation/src/map/canvas/rendering/diff_map_scene.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_render_baseline.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_scene_change.dart';
import 'package:map_presentation/src/map/models/map_content.dart';

import 'support/map_fixtures.dart';

MapRenderBaseline baseline(MapScene? scene) =>
    MapRenderBaseline(content: scene?.content, camera: scene);

void main() {
  final places = MapScene(content: MapContent(layer: sampleLayer));
  final located = places.copyWith(
    content: places.content.copyWith(location: sampleLocation),
  );

  test('turning the phone updates the arrow without moving the camera', () {
    final before = located.copyWith(focus: MapCameraFocus.userLocation);
    final after = before.copyWith(
      content: before.content.copyWith(
        location: LocationFix(
          point: GeoPoint(
            latitude: sampleLocation.point.latitude,
            longitude: sampleLocation.point.longitude,
          ),
          accuracyMeters: 12,
          bearing: const LocationBearing(
            degrees: 90,
            source: LocationBearingSource.compass,
          ),
        ),
      ),
    );
    expect(diffMapScene(baseline(before), after), [isA<MapLocationChanged>()]);
  });

  test('a new GPS position follows without resetting the zoom', () {
    final before = located.copyWith(focus: MapCameraFocus.userLocation);
    final after = before.copyWith(
      content: before.content.copyWith(
        location: const LocationFix(
          point: GeoPoint(latitude: -6.21, longitude: 106.8),
          accuracyMeters: 12,
        ),
      ),
    );
    expect(diffMapScene(baseline(before), after), [
      isA<MapLocationChanged>(),
      isA<MapCameraChanged>().having(
        (change) => change.reframe,
        'reframe',
        false,
      ),
    ]);
  });

  test('new timestamps and accuracy alone require no native redraw', () {
    final next = located.copyWith(
      content: located.content.copyWith(
        location: LocationFix(
          point: GeoPoint(
            latitude: sampleLocation.point.latitude,
            longitude: sampleLocation.point.longitude,
          ),
          accuracyMeters: 15,
          timestamp: DateTime.utc(2026),
        ),
      ),
    );
    expect(diffMapScene(baseline(located), next), isEmpty);
  });

  test('free camera keeps updating location without following it', () {
    final before = places.copyWith(focus: MapCameraFocus.free);
    expect(
      diffMapScene(
        baseline(before),
        located.copyWith(focus: MapCameraFocus.free),
      ),
      [isA<MapLocationChanged>()],
    );
  });

  test(
    'an unknown native baseline replaces both sources, even with empty data',
    () {
      final changes = diffMapScene(baseline(null), const MapScene());
      expect(changes, [
        isA<MapPlacesChanged>().having(
          (change) => change.layer,
          'layer',
          isNull,
        ),
        isA<MapLocationChanged>().having(
          (change) => change.location,
          'location',
          isNull,
        ),
        isA<MapCameraChanged>(),
      ]);
    },
  );
  test('an unchanged scene performs no native work', () {
    expect(diffMapScene(baseline(located), located), isEmpty);
  });
  test(
    'GPS arriving while places are focused only updates the location source',
    () {
      expect(diffMapScene(baseline(places), located), [
        isA<MapLocationChanged>(),
      ]);
    },
  );
  test(
    'GPS arriving while user location is focused also centers the camera',
    () {
      final waiting = places.copyWith(focus: MapCameraFocus.userLocation);
      final ready = located.copyWith(focus: MapCameraFocus.userLocation);
      expect(diffMapScene(baseline(waiting), ready), [
        isA<MapLocationChanged>(),
        isA<MapCameraChanged>(),
      ]);
    },
  );
  test(
    'a layer refresh preserves the camera when user location is focused',
    () {
      final before = located.copyWith(focus: MapCameraFocus.userLocation);
      final after = before.copyWith(
        content: before.content.copyWith(
          layer: MapLayer(name: 'Reloaded', places: [samplePlace]),
        ),
      );
      expect(diffMapScene(baseline(before), after), [isA<MapPlacesChanged>()]);
    },
  );
  test('changing focus moves the camera without rewriting sources', () {
    expect(
      diffMapScene(
        baseline(located),
        located.copyWith(focus: MapCameraFocus.userLocation),
      ),
      [isA<MapCameraChanged>()],
    );
  });
  test('an explicit focus command recenters the same scene', () {
    expect(diffMapScene(baseline(located), located, refocus: true), [
      isA<MapCameraChanged>(),
    ]);
  });
  test('removing content clears native data', () {
    final changes = diffMapScene(baseline(located), const MapScene());
    expect(changes, [
      isA<MapPlacesChanged>().having((change) => change.layer, 'layer', isNull),
      isA<MapLocationChanged>().having(
        (change) => change.location,
        'location',
        isNull,
      ),
      isA<MapCameraChanged>(),
    ]);
  });
}
