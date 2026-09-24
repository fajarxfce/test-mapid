import 'package:map_data/src/dto/map_layer_response.dart';

abstract interface class MapRemoteDataSource {
  Future<MapLayerResponse> loadLayer();
}
