import 'dart:math';

import 'package:core_location_domain/core_location_domain.dart';
import 'package:map_domain/map_domain.dart';

/// Rendering operations for one native map. The widget owns its disposal.
abstract interface class MapSurface {
  bool get isDisposed;
  Future<void> showPlaces(MapLayer layer);
  Future<void> showLocation(LocationFix location);
  Future<String?> placeAt(Point<double> point);
  Future<void> fitPlaces(MapLayer layer);
  Future<void> centerOn(LocationFix location);
  Future<void> zoomBy(double amount);
  Future<void> reloadStyle();
}
