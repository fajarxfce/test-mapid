import 'package:core_common/core_common.dart';
import 'package:map_domain/src/entities/map_layer.dart';

abstract interface class MapRepository {
  Future<Result<MapLayer>> loadLayer();
}
