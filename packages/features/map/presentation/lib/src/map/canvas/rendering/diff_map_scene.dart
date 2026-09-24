import 'package:map_presentation/src/map/canvas/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/canvas/models/map_scene.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_scene_change.dart';

/// Computes native work without performing I/O or modifying either snapshot.
List<MapSceneChange> diffMapScene(
  MapScene? previous,
  MapScene next, {
  bool refocus = false,
}) {
  final placesChanged =
      previous == null || previous.content.layer != next.content.layer;
  final locationChanged =
      previous == null || previous.content.location != next.content.location;
  return [
    if (placesChanged) MapPlacesChanged(next.content.layer),
    if (locationChanged) MapLocationChanged(next.content.location),
    if (refocus ||
        previous?.focus != next.focus ||
        (next.focus == MapCameraFocus.places && placesChanged) ||
        (next.focus == MapCameraFocus.userLocation && locationChanged))
      MapCameraChanged(next),
  ];
}
