import 'package:core_location_domain/core_location_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:map_domain/map_domain.dart';

part 'map_content.freezed.dart';

/// Renderable data, independent of loading and error messages.
@freezed
abstract class MapContent with _$MapContent {
  const factory MapContent({MapLayer? layer, LocationFix? location}) =
      _MapContent;
}
