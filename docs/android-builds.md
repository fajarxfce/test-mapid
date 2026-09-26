# Android builds

Use Flutter 3.47.5, JDK 21 and the Android SDK. Set `JAVA_HOME` to the JDK
installation directory. MapLibre GL 0.27 targets Java 21.

Populate the root `.env`, then run:

```sh
dart run tool/app.dart build android dev --smoke
```

The APK is written to
`apps/fluent_starter/build/app/outputs/flutter-apk/app-dev-debug.apk`.
The application ID is `io.github.fajarxfce.testmapid.dev`. Other flavors use
`.staging` and the unsuffixed production application ID.

Only foreground coarse/fine location permissions are requested. Location is
optional; the map remains available when access is denied or GPS is disabled.

## Recover generated build state

Stop active build/debug sessions, then run from the repository root:

```sh
dart run melos run android:reset --no-select
dart run tool/app.dart build android dev --smoke
```

The reset task stops Gradle, cleans the Flutter application, backs up its
project-local Gradle cache under `android/.cache-backups`, and restores locked
dependencies. It is also available in both editors. If Melos cannot start, use
`dart tool/reset_android.dart` directly.

The Flavorizr-generated Gradle script uses `AppExtension`; the project retains
the compatible legacy DSL settings. Local release APKs use debug signing unless
`android/key.properties` configures a release key. The GitHub release workflow
requires a persistent signing key and the real layer configuration through
repository secrets. See [GitHub releases](releases.md).

The regular verification workflow uses placeholder layer credentials to check
Android compilation without using the configured API key.
