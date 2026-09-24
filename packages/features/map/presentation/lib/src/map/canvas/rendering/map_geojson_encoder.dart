import 'package:core_location_domain/core_location_domain.dart';
import 'package:map_domain/map_domain.dart';

Map<String, dynamic> placesGeoJson(MapLayer? layer) => {
  'type': 'FeatureCollection',
  'features': [
    for (final place in layer?.places ?? <MapPlace>[])
      {
        'type': 'Feature',
        'id': place.id,
        'properties': {'place_id': place.id},
        'geometry': {
          'type': 'Point',
          'coordinates': [place.point.longitude, place.point.latitude],
        },
      },
  ],
};

Map<String, dynamic> locationGeoJson(LocationFix? location) => {
  'type': 'FeatureCollection',
  'features': [
    if (location != null)
      {
        'type': 'Feature',
        'properties': <String, dynamic>{},
        'geometry': {
          'type': 'Point',
          'coordinates': [location.point.longitude, location.point.latitude],
        },
      },
  ],
};
