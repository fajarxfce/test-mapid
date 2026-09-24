# Validation

Validated with Flutter 3.47.5, Dart 3.13.4, JDK 21, and Android SDK 36.

## Automated checks

- `dart run melos run generate --no-select`: passed; generated sources reproduce
  the committed output.
- `dart run melos run check --no-select`: passed, including formatting,
  dependency boundaries, architecture rules, static analysis, and 234 tests.
- Flavor generation and native scheme checks: passed.
- Android dev universal release and staging ARM64 release builds: passed. Both
  APK signatures were verified with Android SDK `apksigner`. Earlier debug-build
  device verification is recorded below.
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

## Clean Architecture boundary regressions

- Location datasources expose DTOs and preserve technical exceptions. Tests
  verify that synchronous, asynchronous, and stream failures become domain
  failures in the repository, including permanent permission denial.
- Compass failure preserves GPS tracking and falls back to movement bearing.
  Permission recovery, passive resume, and sensor cancellation remain covered.
- The production AutoRoute configuration and generated Injectable registrations
  create a shared route-owned renderer. Its native callbacks make the canvas
  ready, late observers receive the latest status, and removing the route closes
  the Bloc and renderer. Only the native platform surface/controller is mocked.
- Renderer tests cover controller replacement and independent session cleanup.
  Session timeout tests advance a controlled clock and check timer cancellation.
- Architecture checks reject domain imports and Result/Failure wrappers in raw
  datasources/DTOs, and SDK imports in Bloc events, states, and the renderer port.

The boundary refactor passed all 234 automated tests and both release builds.
It has not been retested on the physical phone because the device remained
locked. The device observations below describe earlier builds.

## Map audit regressions

| Boundary | Regression coverage |
| --- | --- |
| SDK widget construction | The production `MapCanvas` and installed `MapLibreMap` widget build with assertions enabled. Only the native platform surface is replaced. |
| Pending render work | A gated source write followed by 12 GPS fixes writes the in-flight and newest positions only. A pan supersedes the captured follow intent; explicit zoom remains ordered. Camera progress continues when each write receives another fix. |
| Native failures | A failed hit test followed by a compass update does not rewrite places or move the camera. Camera retries preserve confirmed sources. Partial source failures, style replacement, and disposal are exercised separately. |
| Dataset equality and selection | Independently reconstructed equal layers require no source rewrite or camera fit. Stable place IDs retain the popup, changed attributes update it, and removed IDs clear it. |
| Gesture boundary | Tap jitter preserves follow; deliberate drags still reach the underlying surface. Cancellation and disposal release pointer tracking. |
| Rebuild scope | Ten compass updates preserve the header and overlay widget instances while the bearing label updates. Layer and selection changes still render. |

Renderer tests use controllable native-controller doubles to reproduce ordering
and failures. They do not establish GPU rendering behavior. The production
canvas smoke test covers the SDK constructor boundary; device checks below cover
actual native rendering and touch delivery.

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

### Audit follow-up build

Debug build `8a398da` was installed on the same device with assertions enabled.
Read-only VM inspection confirmed that the actual canvas Bloc reached `ready`.
A small touch movement preserved `userLocation` focus; a deliberate drag changed
it to `free`, and **Lokasi saya** restored follow. Pixel checks independently
confirmed native map movement and recentering on the GPS marker. No Flutter
assertions or Android fatal exceptions appeared in the app process log.

GEO MAPID requests from the phone timed out during this follow-up, including a
manual retry. The app displayed its connection warning while the map and GPS
remained usable. Fresh tourism loading, feature picking, and popup preservation
across an HTTP refresh were therefore not reverified on this build's device run;
the new equality and selection behavior is covered by the regression tests above.
The earlier successful tourism checks remain baseline evidence, not a claim
that the final device run loaded that dataset.

### Permission recovery and label stability

The permission-recovery changes were verified on the same Galaxy A72 using an
ARM64 staging release. The device's existing dev installation used a different
signing certificate, so staging was installed separately.

- With location permanently denied, Liberty and all 10 tourism features loaded;
  no basemap or tourism connection warning was displayed.
- The recovery button opened Android application settings. While settings were
  foreground, foreground location permission was granted with ADB. Returning to
  the app resumed GPS and compass automatically, without another location tap.
  The Android process ID remained unchanged and the tourism layer was retained.
- The earlier data error was a connection timeout followed by a successful HTTP
  200. Location permission and map network loading are independent; timeouts were
  not increased or suppressed.
- A 12-second screen recording reproduced repeated road/building label fades
  during GPS follow in the existing dev build. A second recording of the staging
  release showed stable labels after changing follow updates to `easeCamera`.
  GPS and compass remained active throughout the comparison. Initial camera
  transitions and ordinary position drift are separate from the repeated fades.

Regression tests cover passive permission checks, recovery after permanent
denial and disabled GPS, repeated resumes without new permission prompts,
explicit retry cancellation, and center-only camera easing during GPS follow.
