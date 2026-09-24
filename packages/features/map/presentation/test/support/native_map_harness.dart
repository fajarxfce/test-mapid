import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mocktail/mocktail.dart';

import 'mock_map_controller.dart';

/// An in-memory native style behind the real renderer, layers and camera.
class NativeMapHarness {
  NativeMapHarness() {
    when(() => controller.isDisposed).thenReturn(false);
    when(controller.getSourceIds)
        .thenAnswer((_) async => sources.keys.toList());
    when(controller.getLayerIds).thenAnswer((_) async => layers.toList());
    when(() => controller.addGeoJsonSource(any(), any())).thenAnswer(
      (call) => _write(
        call.positionalArguments[0] as String,
        call.positionalArguments[1] as Map<String, dynamic>,
      ),
    );
    when(() => controller.setGeoJsonSource(any(), any())).thenAnswer(
      (call) => _write(
        call.positionalArguments[0] as String,
        call.positionalArguments[1] as Map<String, dynamic>,
      ),
    );
    when(
      () => controller.addCircleLayer(
        any(),
        any(),
        any(),
        enableInteraction: false,
      ),
    ).thenAnswer((call) async {
      expectSync(sources, contains(call.positionalArguments[0]));
      layers.add(call.positionalArguments[1] as String);
    });
    when(() => controller.animateCamera(any())).thenAnswer((call) async {
      final command = (call.positionalArguments[0] as CameraUpdate).toJson();
      operations.add('camera');
      cameraMoves.add(command);
      await onCamera?.call();
      return true;
    });
    when(
      () => controller.easeCamera(
        any(),
        duration: any(named: 'duration'),
        interpolation: any(named: 'interpolation'),
      ),
    ).thenAnswer((call) async {
      final command = (call.positionalArguments[0] as CameraUpdate).toJson();
      operations.add('camera');
      cameraMoves.add(command);
      await onCamera?.call();
      return true;
    });
    when(() => controller.addImage(any(), any())).thenAnswer((_) async {});
    when(
      () => controller.addSymbolLayer(
        any(),
        any(),
        any(),
        filter: any<dynamic>(named: 'filter'),
        enableInteraction: false,
      ),
    ).thenAnswer((call) async {
      layers.add(call.positionalArguments[1] as String);
    });
    when(() => controller.setStyle(any())).thenAnswer((_) async {
      operations.add('reload');
      sources.clear();
      layers.clear();
    });
    when(() => controller.queryRenderedFeaturesInRect(any(), any(), null))
        .thenAnswer((_) async {
          operations.add('query');
          return await onQuery?.call() ??
              [
                {
                  'properties': {'place_id': 'place-1'},
                },
              ];
        });
  }

  final controller = TestMapController();
  final sources = <String, Map<String, dynamic>>{};
  final layers = <String>{};
  final operations = <String>[];
  final cameraMoves = <dynamic>[];
  Future<void> Function(String, Map<String, dynamic>)? onWrite;
  Future<List<dynamic>> Function()? onQuery;
  Future<void> Function()? onCamera;

  Future<void> _write(String id, Map<String, dynamic> data) async {
    operations.add(id);
    await onWrite?.call(id, data);
    sources[id] = data;
  }
}
