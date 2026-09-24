import 'package:map_presentation/src/map/canvas/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/canvas/models/map_scene.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_render_baseline.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_scene_change.dart';

/// Computes native work without performing I/O or modifying either snapshot.
List<MapSceneChange> diffMapScene(
  MapRenderBaseline previous,
  MapScene next, {
  bool refocus = false,
}) {
  final placesChanged =
      previous.content == null || previous.content?.layer != next.content.layer;
  final before = previous.content?.location;
  final after = next.content.location;
  final positionChanged =
      before?.point.latitude != after?.point.latitude ||
      before?.point.longitude != after?.point.longitude;
  final locationChanged =
      previous.content == null ||
      positionChanged ||
      before?.bearing?.degrees != after?.bearing?.degrees;
  final camera = previous.camera;
  final cameraLocation = camera?.content.location;
  final cameraPositionChanged =
      cameraLocation?.point.latitude != after?.point.latitude ||
      cameraLocation?.point.longitude != after?.point.longitude;
  return [
    if (placesChanged) MapPlacesChanged(next.content.layer),
    if (locationChanged) MapLocationChanged(next.content.location),
    if (refocus ||
        camera?.focus != next.focus ||
        (next.focus == MapCameraFocus.places &&
            camera?.content.layer != next.content.layer) ||
        (next.focus == MapCameraFocus.userLocation && cameraPositionChanged))
      MapCameraChanged(
        next,
        reframe:
            refocus || camera?.focus != next.focus || cameraLocation == null,
      ),
  ];
}
