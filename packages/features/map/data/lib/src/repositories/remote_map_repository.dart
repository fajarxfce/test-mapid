import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:injectable/injectable.dart';
import 'package:map_data/src/datasources/remote/map_remote_data_source.dart';
import 'package:map_data/src/mappers/map_layer_mapper.dart';
import 'package:map_domain/map_domain.dart';

@LazySingleton(as: MapRepository)
final class RemoteMapRepository implements MapRepository {
  const RemoteMapRepository(this._remote);
  final MapRemoteDataSource _remote;
  @override
  Future<Result<MapLayer>> loadLayer() =>
      safeApiCall(() async => mapLayer(await _remote.loadLayer()));
}
