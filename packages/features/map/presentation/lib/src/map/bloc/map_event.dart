import 'package:map_presentation/src/map/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/models/map_canvas_status.dart';

sealed class MapEvent {
  const MapEvent();
}

final class MapLayerRequested extends MapEvent {
  const MapLayerRequested();
}

final class MapLocationRequested extends MapEvent {
  const MapLocationRequested();
}

final class MapLocationActionRequested extends MapEvent {
  const MapLocationActionRequested();
}

final class MapPanned extends MapEvent {
  const MapPanned();
}

final class MapCanvasStatusChanged extends MapEvent {
  const MapCanvasStatusChanged(this.status);
  final MapCanvasStatus status;
}

final class MapCanvasRetryRequested extends MapEvent {
  const MapCanvasRetryRequested();
}

final class MapPlaceSelected extends MapEvent {
  const MapPlaceSelected(this.id);
  final String? id;
}

final class MapSelectionCleared extends MapEvent {
  const MapSelectionCleared();
}

final class MapFocusRequested extends MapEvent {
  const MapFocusRequested(this.focus);
  final MapCameraFocus focus;
}

final class MapZoomRequested extends MapEvent {
  const MapZoomRequested(this.amount);
  final double amount;
}
