import 'package:injectable/injectable.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_libre_surface.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_surface.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// The controller is only available after native map creation, not at app boot.
@injectable
class MapLibreSurfaceFactory {
  MapSurface create(MapLibreMapController controller) =>
      MapLibreSurface(controller);
}
