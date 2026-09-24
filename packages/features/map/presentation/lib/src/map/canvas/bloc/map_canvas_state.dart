import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:map_presentation/src/map/canvas/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/canvas/models/map_canvas_failure.dart';
import 'package:map_presentation/src/map/canvas/models/map_canvas_status.dart';
import 'package:map_presentation/src/map/models/map_content.dart';
import 'package:map_presentation/src/map/models/place_details.dart';

part 'map_canvas_state.freezed.dart';

@freezed
abstract class MapCanvasState with _$MapCanvasState {
  const MapCanvasState._();
  const factory MapCanvasState({
    @Default(MapContent()) MapContent content,
    @Default(MapCanvasStatus.waitingForMap) MapCanvasStatus status,
    @Default(MapCameraFocus.places) MapCameraFocus focus,
    PlaceDetails? selected,
    MapCanvasFailure? failure,
  }) = _MapCanvasState;

  bool get ready => status == MapCanvasStatus.ready;
  String? get errorMessage => failure?.message;
}
