import 'package:core_location_domain/core_location_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:map_domain/map_domain.dart';

part 'map_scene.freezed.dart';

/// Desired map data and camera intent, independent of native resources.
@freezed
abstract class MapScene with _$MapScene {
  const factory MapScene({
    MapLayer? layer,
    LocationFix? location,
    @Default(MapCameraFocus.places) MapCameraFocus focus,
  }) = _MapScene;
}

enum MapCameraFocus { places, userLocation, free }
