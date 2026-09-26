import 'package:map_domain/map_domain.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Owns only tourism annotations. The SDK owns their source and style layer.
final class TourismMarkers {
  TourismMarkers(this._controller);
  final MapLibreMapController _controller;
  MapLayer? _applied;
  bool _closed = false;

  Future<void> show(MapLayer? layer) async {
    if (_closed ||
        _controller.isDisposed ||
        (layer != null && layer == _applied)) {
      return;
    }
    // An SDK call can mutate its annotation collection before the native write
    // fails. Reconcile by ownership, including annotations from a failed add.
    _applied = null;
    final previous = _controller.circles
        .where((circle) => circle.data?['place_id'] is String)
        .toList();
    if (previous.isNotEmpty) await _controller.removeCircles(previous);
    if (_closed || _controller.isDisposed) return;
    if (layer != null && layer.places.isNotEmpty) {
      await _controller.addCircles(
        [
          for (final place in layer.places)
            CircleOptions(
              geometry: LatLng(place.point.latitude, place.point.longitude),
              circleRadius: 5,
              circleColor: '#16803C',
              circleStrokeColor: '#FFFFFF',
              circleStrokeWidth: 1.5,
            ),
        ],
        [
          for (final place in layer.places) {'place_id': place.id},
        ],
      );
    }
    if (!_closed && !_controller.isDisposed) _applied = layer;
  }

  String? placeId(Circle circle) =>
      !_closed && _controller.circles.contains(circle)
      ? (circle.data?['place_id'] as String?)
      : null;

  void close() => _closed = true;
}
