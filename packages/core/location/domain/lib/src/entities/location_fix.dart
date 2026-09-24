import 'package:core_common/core_common.dart';

final class LocationFix {
  const LocationFix({required this.point, required this.accuracyMeters});
  final GeoPoint point;
  final double accuracyMeters;
}
