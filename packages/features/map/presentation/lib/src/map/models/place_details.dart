import 'package:equatable/equatable.dart';
import 'package:map_domain/map_domain.dart';

final class PlaceDetails extends Equatable {
  const PlaceDetails({
    required this.id,
    required this.name,
    required this.address,
    required this.area,
    required this.period,
    required this.coordinates,
  });
  factory PlaceDetails.fromPlace(MapPlace place) => PlaceDetails(
    id: place.id,
    name: place.name.trim().isEmpty ? 'Lokasi wisata' : place.name,
    address: place.address.trim().isEmpty
        ? 'Alamat belum tersedia'
        : place.address,
    area: [
      place.district,
      place.city,
    ].where((value) => value.trim().isNotEmpty).join(', '),
    period: place.period.isEmpty ? 'Tidak tersedia' : place.period,
    coordinates:
        '${place.point.latitude.toStringAsFixed(5)}, ${place.point.longitude.toStringAsFixed(5)}',
  );
  final String id;
  final String name;
  final String address;
  final String area;
  final String period;
  final String coordinates;

  @override
  List<Object> get props => [id, name, address, area, period, coordinates];
}
