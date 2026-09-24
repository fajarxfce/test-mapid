import 'dart:math';

import 'package:core_location_domain/core_location_domain.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_libre_surface_factory.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_surface.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mocktail/mocktail.dart';

class TestMapController extends Mock implements MapLibreMapController {}

class FakeMapSurface implements MapSurface {
  @override
  bool isDisposed = false;
  final calls = <String>[];
  String? picked = 'place-1';
  Future<void> Function(MapLayer)? onShowPlaces;
  @override
  Future<void> showPlaces(MapLayer layer) async {
    calls.add('places:${layer.name}');
    await onShowPlaces?.call(layer);
  }

  @override
  Future<void> showLocation(LocationFix location) async {
    calls.add('location');
  }

  @override
  Future<void> fitPlaces(MapLayer layer) async {
    calls.add('fit:${layer.name}');
  }

  @override
  Future<void> centerOn(LocationFix location) async {
    calls.add('center');
  }

  @override
  Future<void> zoomBy(double amount) async {
    calls.add('zoom:$amount');
  }

  @override
  Future<String?> placeAt(Point<double> point) async {
    calls.add('query');
    return picked;
  }

  @override
  Future<void> reloadStyle() async {
    calls.add('reload');
  }
}

class FakeSurfaceFactory extends MapLibreSurfaceFactory {
  FakeMapSurface surface = FakeMapSurface();
  int creations = 0;
  @override
  MapSurface create(MapLibreMapController controller) {
    creations++;
    return surface;
  }
}
