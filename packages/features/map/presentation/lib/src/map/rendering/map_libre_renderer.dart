import 'dart:math';
import 'dart:ui';

import 'package:core_location_domain/core_location_domain.dart';
import 'package:injectable/injectable.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/rendering/map_style.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Presentation adapter for the native map. The widget owns controller disposal.
/// MapBloc serializes scene updates and owns data, selection and camera intent.
@injectable
class MapLibreRenderer {
  MapLibreMapController? _controller;
  void attach(MapLibreMapController controller) => _controller = controller;
  void detach() => _controller = null;

  Future<void> renderLayer(MapLayer layer) async {
    final controller = _controller;
    if (controller == null || controller.isDisposed) return;
    final data = <String, dynamic>{
      'type': 'FeatureCollection',
      'features': [
        for (final place in layer.places)
          {
            'type': 'Feature',
            'id': place.id,
            'properties': {'place_id': place.id},
            'geometry': {
              'type': 'Point',
              'coordinates': [place.point.longitude, place.point.latitude],
            },
          },
      ],
    };
    final sources = await controller.getSourceIds();
    if (sources.contains(MapStyle.placesSource)) {
      await controller.setGeoJsonSource(MapStyle.placesSource, data);
    } else {
      await controller.addGeoJsonSource(MapStyle.placesSource, data);
      await controller.addCircleLayer(
        MapStyle.placesSource,
        MapStyle.placesLayer,
        const CircleLayerProperties(
          circleRadius: 9,
          circleColor: '#E77536',
          circleStrokeColor: '#FFFFFF',
          circleStrokeWidth: 2.5,
        ),
        enableInteraction: false,
      );
    }
  }

  Future<void> renderLocation(LocationFix location) async {
    final controller = _controller;
    if (controller == null || controller.isDisposed) return;
    final data = <String, dynamic>{
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'properties': <String, dynamic>{},
          'geometry': {
            'type': 'Point',
            'coordinates': [location.point.longitude, location.point.latitude],
          },
        },
      ],
    };
    final sources = await controller.getSourceIds();
    if (sources.contains(MapStyle.locationSource)) {
      await controller.setGeoJsonSource(MapStyle.locationSource, data);
    } else {
      await controller.addGeoJsonSource(MapStyle.locationSource, data);
      await controller.addCircleLayer(
        MapStyle.locationSource,
        MapStyle.locationLayer,
        const CircleLayerProperties(
          circleRadius: 9,
          circleColor: '#1468D4',
          circleStrokeColor: '#FFFFFF',
          circleStrokeWidth: 3,
        ),
        enableInteraction: false,
      );
    }
  }

  Future<String?> placeAt(Point<double> point) async {
    final controller = _controller;
    if (controller == null || controller.isDisposed) return null;
    final features = await controller.queryRenderedFeaturesInRect(
      Rect.fromCenter(center: Offset(point.x, point.y), width: 28, height: 28),
      [MapStyle.placesLayer],
      null,
    );
    for (final feature in features) {
      if (feature case {'properties': {'place_id': final String id}}) return id;
    }
    return null;
  }

  Future<void> fitLayer(MapLayer layer) async {
    final controller = _controller;
    if (controller == null || controller.isDisposed || layer.places.isEmpty) {
      return;
    }
    if (layer.places.length == 1) {
      final point = layer.places.single.point;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(point.latitude, point.longitude), 14),
      );
      return;
    }
    final latitudes = layer.places.map((place) => place.point.latitude);
    final longitudes = layer.places.map((place) => place.point.longitude);
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(latitudes.reduce(min), longitudes.reduce(min)),
          northeast: LatLng(latitudes.reduce(max), longitudes.reduce(max)),
        ),
        left: 48,
        right: 72,
        top: 64,
        bottom: 140,
      ),
    );
  }

  Future<void> focusLocation(LocationFix location) async {
    final controller = _controller;
    if (controller == null || controller.isDisposed) return;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.point.latitude, location.point.longitude),
        15,
      ),
    );
  }

  Future<void> zoom(double amount) async {
    final controller = _controller;
    if (controller == null || controller.isDisposed) return;
    await controller.animateCamera(CameraUpdate.zoomBy(amount));
  }

  Future<void> reloadStyle() async {
    final controller = _controller;
    if (controller == null || controller.isDisposed) return;
    await controller.setStyle(MapStyle.liberty);
  }
}
