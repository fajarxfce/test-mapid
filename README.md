# MAPID Explorer

A Flutter mobile application featuring an OpenFreeMap basemap, a GEO MAPID
tourism layer, interactive place details, and the user's current location.

This repository was generated from
[fajarxfce/flutter-starter](https://github.com/fajarxfce/flutter-starter).
It uses a modular Melos workspace with clean architecture, Bloc, Injectable,
AutoRoute, Retrofit/JsonSerializable, and a Fluent UI design system.

## Getting started

Requires **Flutter 3.47.5 / Dart 3.13.4**, as specified in `.fvmrc`, and **JDK 21**
for Android builds. Set `JAVA_HOME` to the JDK installation directory.

```sh
cp .env.example .env
# Populate MAPID_API_KEY, MAPID_LAYER_ID, and MAPID_PROJECT_ID.
flutter pub get
dart run melos bootstrap
dart run tool/app.dart run android dev
```

The root `.env` file is excluded from version control. Configuration is passed
through `--dart-define-from-file`; environment values are embedded in the APK.

## Build and verification

```sh
dart run melos run generate --no-select
dart run melos run check --no-select
# Release APK; append --smoke for a debug APK.
dart run tool/app.dart build android dev
```

APK output: `apps/fluent_starter/build/app/outputs/flutter-apk/app-dev-release.apk`
or `app-dev-debug.apk`. Case-study release builds use local debug signing.
VS Code and Zed configurations include run, debug, build, and maintenance tasks.

## Project structure

- `apps/fluent_starter`: application bootstrap, configuration, and composition.
- `packages/features/map/domain`: entities, repository contracts, and use cases.
- `packages/features/map/data`: API services, DTOs, data sources, and repositories.
- `packages/features/map/presentation`: Bloc, MapLibre renderer, routes, and UI.
- `packages/core/location/{domain,data}`: shared location contracts, use cases,
  permissions, and the Geolocator adapter.
- `packages/core`: shared results, error handling, networking, and design system.

## Map and location

[MapLibre GL](https://maplibre.org/flutter-maplibre-gl/) renders the
[OpenFreeMap Liberty](https://tiles.openfreemap.org/styles/liberty) basemap.
GEO MAPID provides the tourism layer. Tapping a point displays its name, address,
and additional attributes. Foreground location access displays the user's
position. The map remains available when location permission is denied.

An internet connection is required to load the basemap and layer data.
