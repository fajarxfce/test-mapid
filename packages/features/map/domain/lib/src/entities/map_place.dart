import 'package:core_common/core_common.dart';
import 'package:equatable/equatable.dart';

final class MapPlace extends Equatable {
  const MapPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.district,
    required this.period,
    required this.point,
  });
  final String id;
  final String name;
  final String address;
  final String city;
  final String district;
  final String period;
  final GeoPoint point;

  @override
  List<Object> get props => [id, name, address, city, district, period, point];
}
