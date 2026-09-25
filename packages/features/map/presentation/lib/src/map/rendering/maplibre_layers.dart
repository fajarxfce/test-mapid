import 'dart:math';
import 'dart:ui';

import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle, Uint8List;
import 'package:map_domain/map_domain.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Owns style sources, layer paint, and native feature queries.
class MapLibreLayers {
  const MapLibreLayers(this._controller);
  final MapLibreMapController _controller;

  Future<void> showPlaces(MapLayer? layer) => _replaceCircleData(
    sourceId: _placesSource,
    layerId: _placesLayer,
    data: _placesGeoJson(layer),
    paint: const CircleLayerProperties(
      circleRadius: 9,
      circleColor: '#E77536',
      circleStrokeColor: '#FFFFFF',
      circleStrokeWidth: 2.5,
    ),
  );

  Future<void> showLocation(LocationFix? location) async {
    await _replaceCircleData(
      sourceId: _locationSource,
      layerId: _locationLayer,
      data: _locationGeoJson(location),
      paint: const CircleLayerProperties(
        circleRadius: 9,
        circleColor: '#1468D4',
        circleStrokeColor: '#FFFFFF',
        circleStrokeWidth: 3,
      ),
    );
    if (_controller.isDisposed || location?.bearing == null) return;
    final layers = await _controller.getLayerIds();
    if (_controller.isDisposed || layers.contains(_headingLayer)) {
      return;
    }
    // Native MapLibre interprets image bytes at screen density; web uses 1x.
    final image = await _loadHeadingImage();
    if (_controller.isDisposed) return;
    await _controller.addImage(_headingImage, image);
    if (_controller.isDisposed) return;
    await _controller.addSymbolLayer(
      _locationSource,
      _headingLayer,
      const SymbolLayerProperties(
        iconImage: _headingImage,
        iconSize: 0.8,
        iconRotate: ['get', 'bearing'],
        iconRotationAlignment: 'map',
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
      ),
      filter: [
        '!=',
        ['get', 'bearing'],
        null,
      ],
      enableInteraction: false,
    );
  }

  Future<void> _replaceCircleData({
    required String sourceId,
    required String layerId,
    required Map<String, dynamic> data,
    required CircleLayerProperties paint,
  }) async {
    final sources = await _controller.getSourceIds();
    if (_controller.isDisposed) return;
    if (sources.contains(sourceId)) {
      await _controller.setGeoJsonSource(sourceId, data);
    } else {
      await _controller.addGeoJsonSource(sourceId, data);
    }
    if (_controller.isDisposed) return;
    // Source and layer creation can fail independently. Reconcile both on retry.
    final layers = await _controller.getLayerIds();
    if (_controller.isDisposed) return;
    if (!layers.contains(layerId)) {
      await _controller.addCircleLayer(
        sourceId,
        layerId,
        paint,
        enableInteraction: false,
      );
    }
  }

  Future<String?> placeAt(Point<double> point) async {
    final features = await _controller.queryRenderedFeaturesInRect(
      Rect.fromCenter(center: Offset(point.x, point.y), width: 28, height: 28),
      [_placesLayer],
      null,
    );
    for (final feature in features) {
      if (feature case {'properties': {'place_id': final String id}}) return id;
    }
    return null;
  }

  Future<Uint8List> _loadHeadingImage() async {
    final ratio = kIsWeb
        ? 1.0
        : PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1.0;
    final bytes = await rootBundle.load(
      'packages/map_presentation/assets/map/heading.png',
    );
    // MapLibre decodes at native display density. Resize the 4x asset to keep
    // its logical size consistent at fractional densities as well as 1x/2x/3x.
    final size = (64 * ratio).ceil();
    final codec = await instantiateImageCodec(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      targetWidth: size,
      targetHeight: size,
    );
    try {
      final frame = await codec.getNextFrame();
      try {
        final png = (await frame.image.toByteData(
          format: ImageByteFormat.png,
        ))!;
        return png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes);
      } finally {
        frame.image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }
}

Map<String, dynamic> _placesGeoJson(MapLayer? layer) => {
  'type': 'FeatureCollection',
  'features': [
    for (final place in layer?.places ?? <MapPlace>[])
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

Map<String, dynamic> _locationGeoJson(LocationFix? location) => {
  'type': 'FeatureCollection',
  'features': [
    if (location != null)
      {
        'type': 'Feature',
        'properties': <String, dynamic>{'bearing': location.bearing?.degrees},
        'geometry': {
          'type': 'Point',
          'coordinates': [location.point.longitude, location.point.latitude],
        },
      },
  ],
};

const _placesSource = 'mapid-places';
const _placesLayer = 'mapid-place-points';
const _locationSource = 'user-location';
const _locationLayer = 'user-location-point';
const _headingImage = 'user-heading-arrow';
const _headingLayer = 'user-location-heading';
