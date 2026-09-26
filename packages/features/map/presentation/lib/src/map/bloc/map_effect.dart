import 'package:map_presentation/src/map/models/map_camera_focus.dart';

/// Explicit visual actions are delivered even when page state is unchanged.
sealed class MapEffect {
  const MapEffect();
}

final class FocusMapCamera extends MapEffect {
  const FocusMapCamera(this.focus);
  final MapCameraFocus focus;
}

final class ZoomMapCamera extends MapEffect {
  const ZoomMapCamera(this.amount);
  final double amount;
}

final class ReloadMapCanvas extends MapEffect {
  const ReloadMapCanvas();
}
