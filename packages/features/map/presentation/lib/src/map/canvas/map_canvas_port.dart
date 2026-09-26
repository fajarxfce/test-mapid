import 'package:core_location_domain/core_location_domain.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/models/map_camera_focus.dart';
import 'package:map_presentation/src/map/models/map_canvas_status.dart';

/// Presentation commands and observations; native types stay in the adapter.
abstract interface class MapCanvasPort {
  Stream<MapCanvasStatus> get statuses;
  Stream<String?> get selections;
  void showPlaces(MapLayer? layer);
  void updateLocation(LocationFix? location);
  void focus(MapCameraFocus focus);
  void zoomBy(double amount);
  void retry();
  Future<void> close();
}
