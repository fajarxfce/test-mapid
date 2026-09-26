import 'dart:ui';

import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle, Uint8List;
import 'package:maplibre_gl/maplibre_gl.dart';

/// Displays supplied fixes. Permission, GPS and compass acquisition stay in core.
final class LocationMarker {
  LocationMarker(this._controller);
  final MapLibreMapController _controller;
  GeoPoint? _point;
  ({GeoPoint point, double bearing})? _heading;
  bool _configured = false;
  bool _closed = false;

  Future<void> show(LocationFix? fix) async {
    if (_closed || _controller.isDisposed) return;
    final circle = _controller.circles
        .where((item) => item.data?['role'] == 'user-location')
        .firstOrNull;
    if (fix == null) {
      _point = null;
      if (circle != null) await _controller.removeCircle(circle);
    } else if (_point != fix.point) {
      _point = null;
      final geometry = LatLng(fix.point.latitude, fix.point.longitude);
      if (circle == null) {
        await _controller.addCircle(
          CircleOptions(
            geometry: geometry,
            circleRadius: 6,
            circleColor: '#1468D4',
            circleStrokeColor: '#FFFFFF',
            circleStrokeWidth: 2,
          ),
          {'role': 'user-location'},
        );
      } else {
        await _controller.updateCircle(
          circle,
          CircleOptions(geometry: geometry),
        );
      }
      _point = fix.point;
    }
    if (_closed || _controller.isDisposed) return;
    final symbol = _controller.symbols
        .where((item) => item.data?['role'] == 'user-heading')
        .firstOrNull;
    final heading = fix?.bearing == null
        ? null
        : (point: fix!.point, bearing: fix.bearing!.degrees);
    if (heading == null) {
      _heading = null;
      if (symbol != null) await _controller.removeSymbol(symbol);
      return;
    }
    if (heading == _heading) return;
    _heading = null;
    if (!_configured) {
      final image = await _loadHeadingImage();
      if (_closed || _controller.isDisposed) return;
      await _controller.addImage('user-heading-arrow', image);
      if (_closed || _controller.isDisposed) return;
      // SymbolOptions does not expose alignment/placement. Configure the SDK's
      // symbol layer once per style; annotation geometry still belongs to it.
      for (final id in _controller.symbolManager!.layerIds) {
        await _controller.setLayerProperties(
          id,
          const SymbolLayerProperties(
            iconRotationAlignment: 'map',
            iconAllowOverlap: true,
            iconIgnorePlacement: true,
          ),
        );
        if (_closed || _controller.isDisposed) return;
      }
      _configured = true;
    }
    final options = SymbolOptions(
      geometry: LatLng(heading.point.latitude, heading.point.longitude),
      iconImage: 'user-heading-arrow',
      iconSize: 0.65,
      iconRotate: heading.bearing,
    );
    if (symbol == null) {
      await _controller.addSymbol(options, {'role': 'user-heading'});
    } else {
      await _controller.updateSymbol(symbol, options);
    }
    if (!_closed && !_controller.isDisposed) _heading = heading;
  }

  void close() => _closed = true;

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
