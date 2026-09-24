import 'package:injectable/injectable.dart';
import 'package:map_data/src/config/mapid_layer_config.dart';
import 'package:map_data/src/datasources/remote/map_remote_data_source.dart';
import 'package:map_data/src/dto/map_layer_response.dart';
import 'package:map_data/src/services/mapid_api.dart';

@LazySingleton(as: MapRemoteDataSource)
final class ApiMapRemoteDataSource implements MapRemoteDataSource {
  const ApiMapRemoteDataSource(this._api, this._config);
  final MapidApi _api;
  final MapidLayerConfig _config;
  @override
  Future<MapLayerResponse> loadLayer() =>
      _api.getLayer(_config.apiKey, _config.layerId, _config.projectId);
}
