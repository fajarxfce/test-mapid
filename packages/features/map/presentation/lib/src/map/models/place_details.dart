import 'package:map_domain/map_domain.dart';

final class PlaceDetails {
  const PlaceDetails({
    required this.name,
    required this.address,
    required this.area,
    required this.period,
    required this.coordinates,
  });
  factory PlaceDetails.fromPlace(MapPlace place) => PlaceDetails(
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
  final String name;
  final String address;
  final String area;
  final String period;
  final String coordinates;
}
