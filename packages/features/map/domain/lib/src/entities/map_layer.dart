import 'package:equatable/equatable.dart';
import 'package:map_domain/src/entities/map_place.dart';

/// Content identity includes the name and ordered, immutable place values.
final class MapLayer extends Equatable {
  MapLayer({required this.name, required List<MapPlace> places})
    : places = List.unmodifiable(places);
  final String name;
  final List<MapPlace> places;

  @override
  List<Object> get props => [name, places];
}
