import 'package:core_common/core_common.dart';
import 'package:map_domain/src/entities/map_layer.dart';
import 'package:map_domain/src/repositories/map_repository.dart';

final class LoadMapLayer {
  const LoadMapLayer(this._repository);
  final MapRepository _repository;
  Future<Result<MapLayer>> call() => _repository.loadLayer();
}
