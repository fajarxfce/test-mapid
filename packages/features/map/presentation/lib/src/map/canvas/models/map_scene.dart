import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:map_presentation/src/map/canvas/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/models/map_content.dart';

part 'map_scene.freezed.dart';

/// The desired map content and camera focus, independent of native resources.
@freezed
abstract class MapScene with _$MapScene {
  const factory MapScene({
    @Default(MapContent()) MapContent content,
    @Default(MapCameraFocus.places) MapCameraFocus focus,
  }) = _MapScene;
}
