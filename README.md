# MAPID Explorer

Flutter case study: peta OpenFreeMap, layer pariwisata GEO MAPID, popup
informasi tempat, dan lokasi GPS user. Aplikasi langsung membuka peta.

Repo ini dibuat dari template milik saya:
[fajarxfce/flutter-starter](https://github.com/fajarxfce/flutter-starter).
Fondasinya memakai Melos, clean architecture modular, Bloc, Injectable,
AutoRoute, Retrofit/JsonSerializable, dan komponen Fluent UI.

## Menjalankan

Gunakan **Flutter 3.47.5 / Dart 3.13.4**, sesuai `.fvmrc`.

```sh
cp .env.example .env
# Isi MAPID_API_KEY, MAPID_LAYER_ID, dan MAPID_PROJECT_ID dari brief.
flutter pub get
dart run melos bootstrap
dart run tool/app.dart run android dev
```

`.env` di root repo diabaikan Git. Konfigurasi dibaca melalui
`--dart-define-from-file`, bukan disimpan di source code. Aplikasi mobile
memuat nilai tersebut dalam binary; gunakan key layer dengan akses terbatas.

## Build dan pemeriksaan

```sh
dart run melos run generate --no-select
dart run melos run check --no-select
dart run tool/app.dart build android dev --smoke
```

APK: `apps/fluent_starter/build/app/outputs/flutter-apk/app-dev-debug.apk`.
Task run/debug, build, clean, dan pub get tersedia di VS Code dan Zed.

## Struktur

- `apps/fluent_starter`: bootstrap, konfigurasi, dan komposisi dependency/router.
- `packages/features/map/domain`: entity, kontrak repository, dan use case.
- `packages/features/map/data`: Retrofit, DTO, datasource, dan repository.
- `packages/features/map/presentation`: Bloc, renderer MapLibre, route, dan UI.
- `packages/core`: Result/error, network, dan design system bersama.

Basemap: [OpenFreeMap Liberty](https://tiles.openfreemap.org/styles/liberty).
Renderer: [MapLibre GL](https://maplibre.org/flutter-maplibre-gl/).
Layer memerlukan internet. Izin lokasi hanya diminta untuk lokasi saat ini;
peta dan data wisata tetap dapat digunakan ketika izin ditolak.
