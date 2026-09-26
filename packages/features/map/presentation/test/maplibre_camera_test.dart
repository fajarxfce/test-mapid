import 'package:flutter_test/flutter_test.dart';
import 'package:map_presentation/src/map/models/map_scene.dart';
import 'package:map_presentation/src/map/rendering/maplibre_camera.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mocktail/mocktail.dart';

import 'support/map_fixtures.dart';
import 'support/mock_map_controller.dart';

void main() {
  setUpAll(() => registerFallbackValue(CameraUpdate.zoomBy(1)));

  for (final completed in [true, false, null]) {
    test(
      'animateCamera result $completed follows the platform contract',
      () async {
        final controller = TestMapController();
        when(() => controller.animateCamera(any()))
            .thenAnswer((_) async => completed);
        expect(
          await MapLibreCamera(controller).focus(
            const MapScene(
              focus: MapCameraFocus.userLocation,
              location: sampleLocation,
            ),
            reframe: true,
          ),
          completed == false
              ? MapCameraOutcome.cancelled
              : MapCameraOutcome.applied,
        );
        expect(
          await MapLibreCamera(controller).zoomBy(1),
          completed == false
              ? MapCameraOutcome.cancelled
              : MapCameraOutcome.applied,
        );
      },
    );
  }

  test('cancelled easeCamera remains an explicit cancellation', () async {
    final controller = TestMapController();
    when(
      () => controller.easeCamera(
        any(),
        duration: any(named: 'duration'),
        interpolation: any(named: 'interpolation'),
      ),
    ).thenAnswer((_) async => false);
    expect(
      await MapLibreCamera(controller).focus(
        const MapScene(
          focus: MapCameraFocus.userLocation,
          location: sampleLocation,
        ),
      ),
      MapCameraOutcome.cancelled,
    );
  });

  test(
    'GPS follow eases only the center without the Android flyTo zoom dip',
    () async {
      final controller = TestMapController();
      when(
        () => controller.easeCamera(
          any(),
          duration: const Duration(milliseconds: 800),
          interpolation: CameraAnimationInterpolation.linear,
        ),
      ).thenAnswer((_) async => true);
      await MapLibreCamera(controller).focus(
        const MapScene(
          focus: MapCameraFocus.userLocation,
          location: sampleLocation,
        ),
      );
      final update =
          verify(
                () => controller.easeCamera(
                  captureAny(),
                  duration: const Duration(milliseconds: 800),
                  interpolation: CameraAnimationInterpolation.linear,
                ),
              ).captured.single
              as CameraUpdate;
      expect(
        update.toJson(),
        CameraUpdate.newLatLng(
          LatLng(sampleLocation.point.latitude, sampleLocation.point.longitude),
        ).toJson(),
      );
      verifyNever(() => controller.animateCamera(any()));
    },
  );

  test(
    'explicit recenter still frames the user at street-level zoom',
    () async {
      final controller = TestMapController();
      when(() => controller.animateCamera(any())).thenAnswer((_) async => true);
      await MapLibreCamera(controller).focus(
        const MapScene(
          focus: MapCameraFocus.userLocation,
          location: sampleLocation,
        ),
        reframe: true,
      );
      final update =
          verify(() => controller.animateCamera(captureAny())).captured.single
              as CameraUpdate;
      expect(
        update.toJson(),
        CameraUpdate.newLatLngZoom(
          LatLng(sampleLocation.point.latitude, sampleLocation.point.longitude),
          15,
        ).toJson(),
      );
    },
  );
}
