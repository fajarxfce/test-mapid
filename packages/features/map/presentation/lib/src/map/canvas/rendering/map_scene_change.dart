import 'package:core_location_domain/core_location_domain.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/canvas/models/map_scene.dart';

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
