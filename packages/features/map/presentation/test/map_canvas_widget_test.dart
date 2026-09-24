import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_presentation/src/map/canvas/rendering/map_style.dart';
import 'package:map_presentation/src/map/widgets/map_canvas.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'support/map_platform_view.dart';

void main() {
  testWidgets('production canvas builds with SDK assertions enabled', (
    tester,
  ) async {
    final previous = MapLibrePlatform.createInstance;
    final platform = TestMapPlatformView();
    MapLibrePlatform.createInstance = () => platform;
    addTearDown(() => MapLibrePlatform.createInstance = previous);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: MapCanvas(),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(MapLibreMap), findsOneWidget);
    expect(platform.creationParams?['styleString'], MapStyle.liberty);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
