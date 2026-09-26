import 'dart:math';

import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/models/map_scene.dart';
import 'package:map_presentation/src/map/models/place_details.dart';

/// One-time view operations; persistent content and focus live in MapScene.
sealed class MapEffect {
  const MapEffect();
}

sealed class MapCanvasCommand extends MapEffect {
  const MapCanvasCommand();
}

final class FocusMapCamera extends MapCanvasCommand {
  const FocusMapCamera(this.focus);
  final MapCameraFocus focus;
}

final class ZoomMapCamera extends MapCanvasCommand {
  const ZoomMapCamera(this.amount);
  final double amount;
}

final class ReloadMapCanvas extends MapCanvasCommand {
  const ReloadMapCanvas();
}

/// The originating content/selection lets the Bloc reject a stale pick.
final class PickMapPlace extends MapEffect {
  const PickMapPlace(
    this.point, {
    required this.layer,
    required this.selection,
  });
  final Point<double> point;
  final MapLayer? layer;
  final PlaceDetails? selection;
}
