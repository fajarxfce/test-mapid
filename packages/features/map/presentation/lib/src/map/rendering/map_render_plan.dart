import 'package:core_location_domain/core_location_domain.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/models/map_scene.dart';

/// Confirmed native sources and camera progress can fail independently.
final class MapRenderBaseline {
  const MapRenderBaseline({this.sources, this.camera});
  final MapScene? sources;
  final MapScene? camera;

  MapRenderBaseline afterSuccess(MapSceneChange change) => switch (change) {
    MapPlacesChanged(:final layer) => MapRenderBaseline(
      sources: (sources ?? const MapScene()).copyWith(layer: layer),
      camera: camera,
    ),
    MapLocationChanged(:final location) => MapRenderBaseline(
      sources: (sources ?? const MapScene()).copyWith(location: location),
      camera: camera,
    ),
    MapCameraChanged(:final scene) => MapRenderBaseline(
      sources: sources,
      camera: scene,
    ),
  };
}

/// A finite rendering plan, separate from Bloc input events.
sealed class MapSceneChange {
  const MapSceneChange();
}

final class MapPlacesChanged extends MapSceneChange {
  const MapPlacesChanged(this.layer);
  final MapLayer? layer;
}

final class MapLocationChanged extends MapSceneChange {
  const MapLocationChanged(this.location);
  final LocationFix? location;
}

final class MapCameraChanged extends MapSceneChange {
  const MapCameraChanged(this.scene, {this.reframe = false});
  final MapScene scene;
  final bool reframe;
}

/// Computes native work without performing I/O or modifying either snapshot.
List<MapSceneChange> diffMapScene(
  MapRenderBaseline previous,
  MapScene next, {
  bool refocus = false,
}) {
  final placesChanged =
      previous.sources == null || previous.sources?.layer != next.layer;
  final before = previous.sources?.location;
  final after = next.location;
  final positionChanged =
      before?.point.latitude != after?.point.latitude ||
      before?.point.longitude != after?.point.longitude;
  final locationChanged =
      previous.sources == null ||
      positionChanged ||
      before?.bearing?.degrees != after?.bearing?.degrees;
  final camera = previous.camera;
  final cameraLocation = camera?.location;
  final cameraPositionChanged =
      cameraLocation?.point.latitude != after?.point.latitude ||
      cameraLocation?.point.longitude != after?.point.longitude;
  return [
    if (placesChanged) MapPlacesChanged(next.layer),
    if (locationChanged) MapLocationChanged(next.location),
    if (refocus ||
        camera?.focus != next.focus ||
        (next.focus == MapCameraFocus.places && camera?.layer != next.layer) ||
        (next.focus == MapCameraFocus.userLocation && cameraPositionChanged))
      MapCameraChanged(
        next,
        reframe:
            refocus || camera?.focus != next.focus || cameraLocation == null,
      ),
  ];
}
