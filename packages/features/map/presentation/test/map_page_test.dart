import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core_common/core_common.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_domain/map_domain.dart';
import 'package:map_presentation/src/map/bloc/map_bloc.dart';
import 'package:map_presentation/src/map/bloc/map_event.dart';
import 'package:map_presentation/src/map/bloc/map_state.dart';
import 'package:map_presentation/src/map/models/map_scene.dart';
import 'package:map_presentation/src/map/models/place_details.dart';
import 'package:map_presentation/src/map/pages/map_page.dart';
import 'package:map_presentation/src/map/rendering/map_renderer.dart';
import 'package:map_presentation/src/map/widgets/map_controls.dart';
import 'package:map_presentation/src/map/widgets/place_popup.dart';
import 'package:mocktail/mocktail.dart';

import 'support/map_fixtures.dart';

class MockMapBloc extends MockBloc<MapEvent, MapState> implements MapBloc {}

void main() {
  setUpAll(() => registerFallbackValue(const MapLocationActionRequested()));

  testWidgets('page renders one state and sends one event per user action', (
    tester,
  ) async {
    final bloc = MockMapBloc();
    final states = StreamController<MapState>.broadcast();
    addTearDown(states.close);
    whenListen(
      bloc,
      states.stream,
      initialState: const MapState(renderStatus: MapRenderStatus.ready),
    );
    await tester.pumpWidget(
      FluentApp(
        theme: AppTheme.light(),
        home: BlocProvider<MapBloc>.value(
          value: bloc,
          child: const MapPage(canvas: ColoredBox(color: Colors.white)),
        ),
      ),
    );
    final loaded = MapState(
      scene: MapScene(layer: sampleLayer),
      loadingLayer: false,
      renderStatus: MapRenderStatus.ready,
    );
    states.add(loaded);
    await tester.pumpAndSettle();
    expect(find.text('1 tempat untuk dijelajahi'), findsOneWidget);
    verifyNever(() => bloc.add(any()));

    await tester.tap(find.text('Lokasi saya'));
    final event = verify(() => bloc.add(captureAny())).captured.single;
    expect(event, isA<MapLocationActionRequested>());
    states.add(
      loaded.copyWith(locationStatus: LocationTrackingStatus.acquiring),
    );
    await tester.pump();
    verifyNever(() => bloc.add(any()));
    expect(tester.widget<AppButton>(find.byType(AppButton)).isLoading, isTrue);

    await tester.tap(find.bySemanticsLabel('Lihat semua tempat'));
    verify(
      () => bloc.add(
        any(
          that: isA<MapFocusRequested>().having(
            (event) => event.focus,
            'focus',
            MapCameraFocus.places,
          ),
        ),
      ),
    ).called(1);
    states.add(
      loaded.copyWith(
        scene: loaded.scene.copyWith(location: sampleLocation),
        locationStatus: LocationTrackingStatus.live,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('akurasi ±12 m'), findsOneWidget);
    verifyNever(() => bloc.add(any()));
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'compass updates preserve header and overlays while relevant fields render',
    (tester) async {
      final bloc = MockMapBloc();
      final states = StreamController<MapState>.broadcast();
      addTearDown(states.close);
      final initial = MapState(
        scene: MapScene(layer: sampleLayer, location: sampleLocation),
        loadingLayer: false,
        locationStatus: LocationTrackingStatus.live,
        renderStatus: MapRenderStatus.ready,
      );
      whenListen(bloc, states.stream, initialState: initial);
      await tester.pumpWidget(
        FluentApp(
          theme: AppTheme.light(),
          home: BlocProvider<MapBloc>.value(
            value: bloc,
            child: const MapPage(canvas: ColoredBox(color: Colors.white)),
          ),
        ),
      );
      final header = tester.widget<AppText>(
        find.byWidgetPredicate(
          (widget) => widget is AppText && widget.data == sampleLayer.name,
        ),
      );
      final controls = tester.widget<MapControls>(find.byType(MapControls));
      for (var i = 0; i < 10; i++) {
        states.add(
          initial.copyWith(
            scene: initial.scene.copyWith(
              location: LocationFix(
                point: sampleLocation.point,
                accuracyMeters: 12,
                bearing: LocationBearing(
                  degrees: i.toDouble(),
                  source: LocationBearingSource.compass,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.widget<AppText>(
            find.byWidgetPredicate(
              (widget) => widget is AppText && widget.data == sampleLayer.name,
            ),
          ),
          same(header),
        );
        expect(
          tester.widget<MapControls>(find.byType(MapControls)),
          same(controls),
        );
      }
      expect(find.text('Arah hadap · 9°'), findsOneWidget);
      final selected = initial.copyWith(
        scene: initial.scene.copyWith(
          layer: MapLayer(name: 'Updated layer', places: [samplePlace]),
        ),
        selected: PlaceDetails.fromPlace(samplePlace),
      );
      states.add(selected);
      await tester.pumpAndSettle();
      expect(find.text('Updated layer'), findsOneWidget);
      final popup = tester.widget<PlacePopup>(find.byType(PlacePopup));
      states.add(
        selected.copyWith(
          scene: selected.scene.copyWith(
            location: LocationFix(
              point: sampleLocation.point,
              accuracyMeters: 5,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<PlacePopup>(find.byType(PlacePopup)), same(popup));
      expect(find.text('Museum'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Tutup informasi tempat'));
      verify(() => bloc.add(any(that: isA<MapSelectionCleared>()))).called(1);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'map retry and permanent permission recovery dispatch distinct events',
    (tester) async {
      final bloc = MockMapBloc();
      whenListen(
        bloc,
        const Stream<MapState>.empty(),
        initialState: MapState(
          scene: MapScene(layer: sampleLayer),
          loadingLayer: false,
          locationStatus: LocationTrackingStatus.failed,
          locationFailure: const Failure(
            FailureKind.permissionPermanentlyDenied,
            'internal',
          ),
          renderStatus: MapRenderStatus.styleTimeout,
        ),
      );
      await tester.pumpWidget(
        FluentApp(
          theme: AppTheme.light(),
          home: BlocProvider<MapBloc>.value(
            value: bloc,
            child: const MapPage(canvas: ColoredBox(color: Colors.white)),
          ),
        ),
      );
      await tester.tap(find.text('Muat peta'));
      verify(() => bloc.add(any(that: isA<MapStyleReloadRequested>())))
          .called(1);
      await tester.tap(find.text('Buka izin aplikasi'));
      verify(() => bloc.add(any(that: isA<MapLocationActionRequested>())))
          .called(1);
      expect(find.text('internal'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
