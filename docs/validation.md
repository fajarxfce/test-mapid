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

The release APK installed and launched on an Android 16 device. Interactive
verification of the native basemap, marker selection, and live GPS position is
pending a foreground device session. Automated tests do not replace this check.

To complete the device check:

1. Open the application with internet access and confirm the Liberty basemap
   and all 10 tourism points appear.
2. Tap an orange point and verify its name and address in the popup.
3. Grant foreground location access, select **Lokasi saya**, and confirm the
   blue position marker appears. Use the layer control to return to Jogja.
4. Deny location access or disable GPS and confirm the tourism map remains
   usable with an appropriate recovery action.

An initial native style request encountered a transient DNS lookup failure.
The device subsequently resolved the OpenFreeMap host. Confirm basemap loading
in the foreground and use **Muat peta** to retry if required.
