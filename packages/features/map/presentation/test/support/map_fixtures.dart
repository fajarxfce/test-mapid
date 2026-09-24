import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:map_domain/map_domain.dart';

const samplePlace = MapPlace(
  id: 'place-1',
  name: 'Museum',
  address: 'Jalan Museum',
  city: 'Yogyakarta',
  district: 'Gondomanan',
  period: '2024',
  point: GeoPoint(latitude: -7.8, longitude: 110.36),
);
final sampleLayer = MapLayer(name: 'Jogja', places: [samplePlace]);

MapPlace copySamplePlace({String? name, GeoPoint? point}) => MapPlace(
  id: samplePlace.id,
  name: name ?? samplePlace.name,
  address: samplePlace.address,
  city: samplePlace.city,
  district: samplePlace.district,
  period: samplePlace.period,
  point:
      point ??
      GeoPoint(
        latitude: samplePlace.point.latitude,
        longitude: samplePlace.point.longitude,
      ),
);

const sampleLocation = LocationFix(
  point: GeoPoint(latitude: -6.2, longitude: 106.8),
  accuracyMeters: 12,
);
