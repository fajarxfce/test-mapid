import 'package:map_domain/src/entities/map_place.dart';

final class MapLayer {
  MapLayer({required this.name, required List<MapPlace> places})
    : places = List.unmodifiable(places);
  final String name;
  final List<MapPlace> places;
}
