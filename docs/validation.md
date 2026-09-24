# Validation

Validated with Flutter 3.47.5, Dart 3.13.4, JDK 21, and Android SDK 36.

## Automated checks

- `dart run melos run generate --no-select`: passed; generated sources reproduce
  the committed output.
- `dart run melos run check --no-select`: passed, including formatting,
  dependency boundaries, architecture rules, static analysis, and 135 tests.
- Flavor generation and native scheme checks: passed.
- Android dev debug and release builds: passed. The release APK signature was
  verified with Android SDK `apksigner`.
- The configured GEO MAPID endpoint returned 10 point features in the
  `Pariwisata Jogja` layer. The committed test fixture contains two features and
  excludes API credentials and response user metadata.

Coverage includes GeoJSON parsing and coordinate validation, HTTP failures,
credential-safe logging, location permission and service failures, concurrent
Bloc events, style restoration, popup content, and constrained layouts.

The API key is absent from tracked source and local commit history. The root
`.env` and generated submission artifacts are ignored by Git.

## Android device verification

The release APK was installed and tested on a Samsung Galaxy A72 running
Android 16 on 24 September 2026.

| Scenario | Observed result |
| --- | --- |
| Basemap and data | Liberty tiles and the 10-point tourism layer rendered. |
| Point selection | Tapping a point displayed its name, address, area, period, and coordinates. |
| Popup dismissal | Closing the popup restored the location card. |
| Camera controls | Zoom and the layer control updated the map as expected. |
| Current location | Foreground location access produced a blue position marker; **Lokasi saya** centered the camera on it. |
| Location denied | The tourism layer and popup remained usable. The recovery button opened Android application settings. |
| Permission restored | Location acquisition succeeded again after restoring foreground access. |
| Overlay readability | Cards use solid Fluent surfaces and Android status icons remain visible against the light header. |

The selected point used for popup verification was **BENTARA BUDAYA
YOGYAKARTA (BBY)**, with its address on **JL. SUROTO NO.2**. Native map rendering
and GPS were verified on the device; GPS-disabled and timeout behavior are
covered by automated data-layer tests.
