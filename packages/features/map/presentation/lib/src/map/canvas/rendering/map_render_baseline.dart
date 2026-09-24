import 'package:map_presentation/src/map/canvas/models/map_scene.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_scene_change.dart';
import 'package:map_presentation/src/map/models/map_content.dart';

/// Confirmed native content and camera progress can fail independently.
final class MapRenderBaseline {
  const MapRenderBaseline({this.content, this.camera});
  final MapContent? content;
  final MapScene? camera;

  MapRenderBaseline afterSuccess(MapSceneChange change) => switch (change) {
    MapPlacesChanged(:final layer) => MapRenderBaseline(
      content: (content ?? const MapContent()).copyWith(layer: layer),
      camera: camera,
    ),
    MapLocationChanged(:final location) => MapRenderBaseline(
      content: (content ?? const MapContent()).copyWith(location: location),
      camera: camera,
    ),
    MapCameraChanged(:final scene) => MapRenderBaseline(
      content: content,
      camera: scene,
    ),
  };
}
