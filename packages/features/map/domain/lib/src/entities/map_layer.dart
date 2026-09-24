import 'package:collection/collection.dart';
import 'package:map_domain/src/entities/map_place.dart';

/// Content identity includes the name and ordered, immutable place values.
final class MapLayer {
  MapLayer({required this.name, required List<MapPlace> places})
    : places = List.unmodifiable(places);
  final String name;
  final List<MapPlace> places;

  @override
  bool operator ==(Object other) =>
      other is MapLayer &&
      name == other.name &&
      const ListEquality<MapPlace>().equals(places, other.places);

  @override
  int get hashCode =>
      Object.hash(name, const ListEquality<MapPlace>().hash(places));
}
