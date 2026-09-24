# Validation

Validated with Flutter 3.47.5, Dart 3.13.4, JDK 21, and Android SDK 36.

## Automated checks

- `dart run melos run generate --no-select`: passed; generated sources reproduce
  the committed output.
- `dart run melos run check --no-select`: passed, including formatting,
  dependency boundaries, architecture rules, static analysis, and 200 tests.
- Flavor generation and native scheme checks: passed.
- Android dev debug and release builds: passed. The release APK signature was
  verified with Android SDK `apksigner`.
- The configured GEO MAPID endpoint returned 10 point features in the
  `Pariwisata Jogja` layer. The committed test fixture contains two features and
  excludes API credentials and response user metadata.

Coverage includes GeoJSON parsing and coordinate validation, HTTP failures,
credential-safe logging, shared location permissions and service failures,
successive GPS fixes, compass fallback and throttling, first-fix timeout,
background cancellation and resumption, heading-only updates, and camera follow,
typed canvas handlers, pure scene diffing, UI event bindings, style restoration,
serialized native rendering, partial write rollback, stale feature picks,
controller replacement, disposal during native operations, popup content, and
constrained layouts. See [Map architecture](map-architecture.md) for boundaries
and lifecycle decisions.

The API key is absent from tracked source and local commit history. The root
`.env` and generated submission artifacts are ignored by Git.

## Android device verification

Baseline map interactions were verified with release `c49dffc` on a Samsung
Galaxy A72 running Android 16 on 24 September 2026. Continuous tracking and
compass behavior were subsequently checked on the same device using `7d71ff1`.
A follow-up release corrected the heading image's screen-density scaling and
was installed for native marker and camera verification.

| Scenario | Observed result |
| --- | --- |
| Basemap and data | Liberty tiles and the 10-point tourism layer rendered. |
| Point selection | Tapping a point displayed its name, address, area, period, and coordinates. |
| Popup dismissal | Closing the popup restored the location card. |
| Camera controls | Zoom and the layer control updated the map; repeated focus requests recentered after manual panning. |
| Refresh with GPS focus | Reloading tourism data preserved the camera focus on the user's position. |
| Current location | Foreground location access produced a blue position marker; **Lokasi saya** centered the camera on it. |
| Location denied | The tourism layer remained usable. The recovery button opened Android application settings. |
| Permission restored | Location acquisition succeeded again after restoring foreground access. |
| Overlay readability | Cards use solid Fluent surfaces and Android status icons remain visible against the light header. |
| Continuous GPS | Android showed an active high-accuracy request at a one-second interval, with fresh native location snapshots in three successive samples. The app displayed the live location status. |
| Rotation and movement | The device owner confirmed that rotating and moving the phone changed the displayed bearing and location point. No precise position or measured walking distance was recorded. |
| Heading visibility | The corrected release displayed a distinct directional arrow outside the position dot on the device's high-density screen. |
| Background and resume | Android released this app's GPS and compass subscriptions after backgrounding and registered both again when the app resumed, without another location request. |
| Manual pan while tracking | After dragging the map, it stayed away from the position marker during seven seconds of live updates. **Lokasi saya** restored camera follow. |
| Refresh while tracking | Refreshing the layer preserved the camera's focus on the live position. |
| Runtime errors | No Flutter errors or Android fatal exceptions appeared in the app process log during the final marker and camera checks. |

The selected point used for popup verification was **BENTARA BUDAYA
YOGYAKARTA (BBY)**, with its address on **JL. SUROTO NO.2**. Native map rendering
and GPS were verified on the device; GPS-disabled and timeout behavior are
covered by automated data-layer tests.
