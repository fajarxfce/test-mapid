import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:map_data/src/dto/map_layer_response.dart';
import 'package:retrofit/retrofit.dart';
part 'mapid_api.g.dart';

@RestApi()
@lazySingleton
abstract class MapidApi {
  @factoryMethod
  factory MapidApi(@Named(mapidApi) Dio dio, {@ignoreParam String? baseUrl}) =
      _MapidApi;

  @GET('/layers_new/get_layer')
  Future<MapLayerResponse> getLayer(
    @Query('api_key') String apiKey,
    @Query('layer_id') String layerId,
    @Query('project_id') String projectId,
  );
}
