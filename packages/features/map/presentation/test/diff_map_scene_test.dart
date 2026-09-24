import 'package:flutter_test/flutter_test.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/canvas/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/canvas/models/map_scene.dart';
import 'package:map_presentation/src/map/canvas/rendering/diff_map_scene.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_scene_change.dart';
import 'package:map_presentation/src/map/models/map_content.dart';

import 'support/map_fixtures.dart';

void main() {
  final places = MapScene(content: MapContent(layer: sampleLayer));
  final located = places.copyWith(
    content: places.content.copyWith(location: sampleLocation),
  );

  test(
    'an unknown native baseline replaces both sources, even with empty data',
    () {
      final changes = diffMapScene(null, const MapScene());
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
    expect(diffMapScene(located, located), isEmpty);
  });
  test(
    'GPS arriving while places are focused only updates the location source',
    () {
      expect(diffMapScene(places, located), [isA<MapLocationChanged>()]);
    },
  );
  test(
    'GPS arriving while user location is focused also centers the camera',
    () {
      final waiting = places.copyWith(focus: MapCameraFocus.userLocation);
      final ready = located.copyWith(focus: MapCameraFocus.userLocation);
      expect(diffMapScene(waiting, ready), [
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
      expect(diffMapScene(before, after), [isA<MapPlacesChanged>()]);
    },
  );
  test('changing focus moves the camera without rewriting sources', () {
    expect(
      diffMapScene(
        located,
        located.copyWith(focus: MapCameraFocus.userLocation),
      ),
      [isA<MapCameraChanged>()],
    );
  });
  test('an explicit focus command recenters the same scene', () {
    expect(diffMapScene(located, located, refocus: true), [
      isA<MapCameraChanged>(),
    ]);
  });
  test('removing content clears native data', () {
    final changes = diffMapScene(located, const MapScene());
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
