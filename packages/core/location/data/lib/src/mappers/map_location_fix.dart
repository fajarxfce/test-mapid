import 'package:core_common/core_common.dart';
import 'package:core_location_data/src/dto/location_fix_dto.dart';
import 'package:core_location_domain/core_location_domain.dart';

/// Interprets sensor validity while translating a raw fix into a domain value.
LocationFix mapLocationFix(LocationFixDto fix, {double? compassHeading}) =>
    LocationFix(
      point: GeoPoint(latitude: fix.latitude, longitude: fix.longitude),
      accuracyMeters: fix.accuracy,
      timestamp: fix.timestamp,
      bearing: compassHeading != null
          ? LocationBearing(
              degrees: compassHeading,
              source: LocationBearingSource.compass,
            )
          : (fix.speed ?? 0) >= 0.5 &&
                fix.heading != null &&
                fix.heading!.isFinite &&
                fix.heading! >= 0 &&
                (fix.headingAccuracy ?? -1) >= 0
          ? LocationBearing(
              degrees: fix.heading! % 360,
              source: LocationBearingSource.movement,
            )
          : null,
    );
