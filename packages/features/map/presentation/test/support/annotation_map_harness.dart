import 'dart:typed_data';

import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mocktail/mocktail.dart';

import 'mock_map_controller.dart';

/// Models the SDK's mutate-before-await annotation contract, including failures.
class AnnotationMapHarness {
  AnnotationMapHarness() {
    when(() => controller.isDisposed).thenAnswer((_) => disposed);
    when(() => controller.circles).thenAnswer((_) => circles);
    when(() => controller.symbols).thenAnswer((_) => symbols);
    when(() => controller.onCircleTapped).thenReturn(onCircleTapped);
    when(() => controller.symbolManager).thenReturn(SymbolManager(controller));
    when(() => controller.addCircles(any(), any())).thenAnswer((call) async {
      final options = call.positionalArguments[0] as List<CircleOptions>;
      final data = call.positionalArguments[1] as List<Map<String, dynamic>>;
      final added = [
        for (var i = 0; i < options.length; i++)
          Circle('c${nextId++}', options[i], data[i]),
      ];
      circles.addAll(added);
      await write('addPlaces');
      return added;
    });
    when(() => controller.removeCircles(any())).thenAnswer((call) async {
      circles.removeAll(call.positionalArguments[0] as Iterable<Circle>);
      await write('removePlaces');
    });
    when(() => controller.addCircle(any(), any())).thenAnswer((call) async {
      final circle = Circle(
        'c${nextId++}',
        call.positionalArguments[0] as CircleOptions,
        call.positionalArguments[1] as Map<String, dynamic>,
      );
      circles.add(circle);
      await write('addLocation');
      return circle;
    });
    when(() => controller.updateCircle(any(), any())).thenAnswer((call) async {
      final circle = call.positionalArguments[0] as Circle;
      circle.options = circle.options.copyWith(
        call.positionalArguments[1] as CircleOptions,
      );
      await write('updateLocation');
    });
    when(() => controller.removeCircle(any())).thenAnswer((call) async {
      circles.remove(call.positionalArguments[0]);
      await write('removeLocation');
    });
    when(() => controller.addSymbol(any(), any())).thenAnswer((call) async {
      final symbol = Symbol(
        's${nextId++}',
        call.positionalArguments[0] as SymbolOptions,
        call.positionalArguments[1] as Map<String, dynamic>,
      );
      symbols.add(symbol);
      await write('addHeading');
      return symbol;
    });
    when(() => controller.updateSymbol(any(), any())).thenAnswer((call) async {
      final symbol = call.positionalArguments[0] as Symbol;
      symbol.options = symbol.options.copyWith(
        call.positionalArguments[1] as SymbolOptions,
      );
      await write('updateHeading');
    });
    when(() => controller.removeSymbol(any())).thenAnswer((call) async {
      symbols.remove(call.positionalArguments[0]);
      await write('removeHeading');
    });
    when(() => controller.addImage(any(), any())).thenAnswer((call) async {
      image = call.positionalArguments[1] as Uint8List;
      await write('image');
    });
    when(() => controller.setLayerProperties(any(), any()))
        .thenAnswer((call) async {
          headingStyle = call.positionalArguments[1] as SymbolLayerProperties;
          await write('headingStyle');
        });
    when(() => controller.animateCamera(any())).thenAnswer((call) async {
      cameraMoves.add((call.positionalArguments[0] as CameraUpdate).toJson());
      await write('camera');
      return cameraOutcome;
    });
    when(
      () => controller.easeCamera(
        any(),
        duration: any(named: 'duration'),
        interpolation: any(named: 'interpolation'),
      ),
    ).thenAnswer((call) async {
      cameraMoves.add((call.positionalArguments[0] as CameraUpdate).toJson());
      await write('ease');
      return cameraOutcome ?? true;
    });
    when(() => controller.setStyle(any())).thenAnswer((_) async {
      circles.clear();
      symbols.clear();
      await write('reload');
    });
  }

  final controller = TestMapController();
  final circles = <Circle>{};
  final symbols = <Symbol>{};
  final onCircleTapped = ArgumentCallbacks<Circle>();
  final operations = <String>[];
  final cameraMoves = <dynamic>[];
  bool disposed = false;
  bool? cameraOutcome = true;
  int nextId = 0;
  Uint8List? image;
  SymbolLayerProperties? headingStyle;
  Future<void> Function(String)? onWrite;

  Future<void> write(String name) async {
    operations.add(name);
    await onWrite?.call(name);
  }

  static void registerFallbacks() {
    registerFallbackValue(const CircleOptions());
    registerFallbackValue(const SymbolOptions());
    registerFallbackValue(const SymbolLayerProperties());
    registerFallbackValue(Circle('fallback', const CircleOptions(), {}));
    registerFallbackValue(Symbol('fallback', const SymbolOptions(), {}));
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(CameraUpdate.zoomBy(1));
  }
}
