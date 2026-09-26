import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_presentation/src/map/models/place_details.dart';
import 'package:map_presentation/src/map/widgets/place_details_popup.dart';

void main() {
  testWidgets('popup shows name and address and exposes a close action', (
    tester,
  ) async {
    var closed = false;
    await tester.pumpWidget(
      FluentApp(
        theme: AppTheme.light(),
        home: SizedBox(
          width: 360,
          child: PlaceDetailsPopup(
            details: const PlaceDetails(
              id: 'place-1',
              name: 'Museum Jogja',
              address: 'Jalan Museum 10',
              area: 'Yogyakarta',
              period: 'Q2 2024',
              coordinates: '-7.80000, 110.36000',
            ),
            onClose: () => closed = true,
          ),
        ),
      ),
    );
    expect(find.text('Museum Jogja'), findsOneWidget);
    expect(find.text('Jalan Museum 10'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Tutup informasi tempat'));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
  });
  testWidgets(
    'long attributes remain scrollable on a small display with large text',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 520));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        FluentApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Center(
              child: SizedBox(
                width: 296,
                height: 290,
                child: PlaceDetailsPopup(
                  details: const PlaceDetails(
                    id: 'place-1',
                    name: 'TAMAN TIMUR PASAR BERINGHARJO YOGYAKARTA',
                    address: 'Jalan Sriwedani, Ngupasan, Gondomanan, Yogyakarta, Daerah Istimewa Yogyakarta',
                    area: 'Gondomanan, Yogyakarta',
                    period: 'Q2 2024',
                    coordinates: '-7.79923, 110.36837',
                  ),
                  onClose: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
