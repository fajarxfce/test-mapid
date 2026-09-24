import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_data/src/config/mapid_layer_config.dart';
import 'package:map_data/src/datasources/remote/api_map_remote_data_source.dart';
import 'package:map_data/src/repositories/remote_map_repository.dart';
import 'package:map_data/src/services/mapid_api.dart';
import 'package:map_domain/map_domain.dart';

class _LayerAdapter implements HttpClientAdapter {
  late String body;
  int status = 200;
  RequestOptions? request;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _LayerAdapter adapter;
  late Dio dio;
  late RemoteMapRepository repository;
  late List<String> logs;
  setUp(() {
    adapter = _LayerAdapter()
      ..body = File('test/fixtures/layer.json').readAsStringSync();
    logs = [];
    dio = Dio(BaseOptions(baseUrl: 'https://geoserver.mapid.io'))
      ..httpClientAdapter = adapter
      ..interceptors.add(SafeLoggingInterceptor(logs.add));
    repository = RemoteMapRepository(
      ApiMapRemoteDataSource(
        MapidApi(dio),
        const MapidLayerConfig(
          apiKey: 'test-key-private',
          layerId: 'test-layer',
          projectId: 'test-project',
        ),
      ),
    );
    addTearDown(dio.close);
  });
  test(
    'Retrofit sends the configured query and maps longitude/latitude correctly',
    () async {
      final result = await repository.loadLayer() as Success<MapLayer>;
      expect(adapter.request!.path, '/layers_new/get_layer');
      expect(adapter.request!.queryParameters, {
        'api_key': 'test-key-private',
        'layer_id': 'test-layer',
        'project_id': 'test-project',
      });
      expect(result.value.name, 'Pariwisata Jogja');
      expect(result.value.places, hasLength(2));
      expect(result.value.places.first.point.latitude, -7.799231);
      expect(result.value.places.first.point.longitude, 110.368369);
      expect(result.value.places.first.name, 'TAMAN TIMUR PASAR BERINGHARJO');
      expect(result.value.places.first.address, isNotEmpty);
      expect(logs.join(), isNot(contains('test-key-private')));
      expect(logs.join(), isNot(contains('api_key')));
    },
  );
  test('an empty collection is a successful layer with no places', () async {
    adapter.body = jsonEncode({
      'type': 'FeatureCollection',
      'layer_name': 'Empty',
      'features': <Object>[],
    });
    final result = await repository.loadLayer() as Success<MapLayer>;
    expect(result.value.places, isEmpty);
  });
  for (final coordinates in <List<Object>>[
    [110, 95],
    ['bad', -7],
    [110],
    [181, -7],
  ]) {
    test(
      'rejects malformed coordinates $coordinates without leaking transport data',
      () async {
        final json = jsonDecode(adapter.body) as Map<String, dynamic>;
        final feature =
            (json['features'] as List<dynamic>).first as Map<String, dynamic>;
        final geometry = feature['geometry'] as Map<String, dynamic>;
        geometry['coordinates'] = coordinates;
        adapter.body = jsonEncode(json);
        final result = await repository.loadLayer() as FailureResult<MapLayer>;
        expect(result.failure.kind, FailureKind.invalidResponse);
        expect(result.failure.message, isNot(contains('test-key-private')));
      },
    );
  }
  test(
    'duplicate feature identifiers cannot produce ambiguous selection',
    () async {
      final json = jsonDecode(adapter.body) as Map<String, dynamic>;
      (json['features'] as List).add((json['features'] as List).first);
      adapter.body = jsonEncode(json);
      final result = await repository.loadLayer() as FailureResult<MapLayer>;
      expect(result.failure.kind, FailureKind.invalidResponse);
    },
  );
  test('API failures use the shared safe-call classification', () async {
    adapter.status = 403;
    adapter.body = '{"message":"private server detail"}';
    final result = await repository.loadLayer() as FailureResult<MapLayer>;
    expect(result.failure.kind, FailureKind.forbidden);
    expect(result.failure.message, isNot(contains('private')));
    expect(logs.join(), isNot(contains('test-key-private')));
  });
}
