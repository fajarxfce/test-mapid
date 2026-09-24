import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [320.0, 1280.0]) {
    testWidgets('page scrolls with large text at width $width', (tester) async {
      tester.view.physicalSize = Size(width, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        FluentApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 640),
              textScaler: const TextScaler.linear(2),
            ),
            child: const AppPageBody(
              child: AppCard(
                child: AppBrandHeader(
                  title: 'Fluent Starter',
                  subtitle: 'A foundation for your next app.',
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Fluent Starter'), findsOneWidget);
    });
  }
}
