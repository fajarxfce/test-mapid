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
  final before = previous?.content.location;
  final after = next.content.location;
  final positionChanged =
      before?.point.latitude != after?.point.latitude ||
      before?.point.longitude != after?.point.longitude;
  final locationChanged =
      previous == null ||
      positionChanged ||
      before?.bearing?.degrees != after?.bearing?.degrees;
  return [
    if (placesChanged) MapPlacesChanged(next.content.layer),
    if (locationChanged) MapLocationChanged(next.content.location),
    if (refocus ||
        previous?.focus != next.focus ||
        (next.focus == MapCameraFocus.places && placesChanged) ||
        (next.focus == MapCameraFocus.userLocation && positionChanged))
      MapCameraChanged(
        next,
        reframe: refocus || previous?.focus != next.focus || before == null,
      ),
  ];
}
