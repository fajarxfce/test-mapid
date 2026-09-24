# Android build recovery

Build from the repository root with:

```sh
dart run tool/app.dart build android dev --smoke
```

This produces a debug APK with the demo backend. Select `staging` or `prod` in
place of `dev` as needed. The editor Android run/debug configurations use the
same app and flavors.

## An existing class in bundleLibRuntimeToDirDebug

An error such as this is a failure while copying compiled Java classes into an
Android library's incremental build output:

```text
Execution failed for task ':jni:bundleLibRuntimeToDirDebug'.
JniPlugin.class already exists ... fileStatus=NEW
```

The message indicates an existing destination file where Gradle expects a new
one. It can result from inconsistent generated output and incremental build
state; it does not by itself establish that the application declares duplicate
Java classes. The Kotlin plugin warning printed earlier is a separate message.

Stop active IDE build/debug sessions before recovery. From the repository root,
run the reset task once, then build again:

```sh
dart run melos run android:reset --no-select
dart run tool/app.dart build android dev --smoke
```

In VS Code or Zed, choose **`Android: Reset build cache + pub get`**, then your
usual Android build/debug task. Run these tasks in the checkout on the machine
where the build failed. With a remote editor, tasks execute on the remote host.

The reset stops Gradle daemons, runs `flutter clean` inside
**`apps/fluent_starter`**, moves `android/.gradle` into the ignored
`android/.cache-backups/gradle-*/cache` directory, and restores dependencies with
`flutter pub get --enforce-lockfile`. It prints the backup path and stops if any
step fails. Once builds work, old cache backups can be removed to reclaim space.

If Melos cannot start because package resolution is missing, the same reset is
available without workspace dependencies: `dart tool/reset_android.dart`.
For a fresh checkout, first run **`Workspace: Pub get (locked)`** to generate the
Flutter platform files, including the Gradle wrapper.

Cleaning only the monorepo root does not target this application's build
directory. The cleanup removes generated outputs for this app's other platforms
too; those outputs are recreated by subsequent builds. Dependency versions
remain governed by the committed workspace lockfile.

Do not copy `build/`, `.dart_tool/` or `android/.gradle/` between the VPS and a
laptop. They contain generated and machine-specific state. Run only one Android
build at a time within a checkout. Normal subsequent builds should remain
incremental; cleanup is a recovery step, not a task to run before every build.

If the error returns immediately after this recovery, capture the complete
verbose log before cleaning again:

```sh
cd apps/fluent_starter
flutter build apk --debug --flavor dev \
  --dart-define=FLAVOR=dev --dart-define=BACKEND=demo -v \
  > android-build.log 2>&1
```

That log is needed to distinguish a recurring Gradle/plugin problem from stale
local outputs. Do not add task hooks that delete individual `.class` files or
silently rerun failed tasks.

## flutter_web_auth_2 and Built-in Kotlin

As checked on 2026-09-24, pub.dev's latest stable `flutter_web_auth_2` is **5.1.0**.
Its Android build script still applies `kotlin-android`. The plugin's **6.0.0
alpha** releases migrate to Built-in Kotlin; they are not stable releases.

The project retains Flutter's existing `android.builtInKotlin=false` and
`android.newDsl=false` compatibility settings. The KGP warning is expected with
this dependency version, and is not the cause of an existing `JniPlugin.class`
destination. Debug APK builds currently succeed with the warning.

When a compatible stable plugin is available, update its version centrally in
`pubspec_overrides.yaml`, follow the Flutter migration guide for the app's
Gradle configuration, and validate Android builds and OAuth integration. Merely
hiding the warning or enabling Built-in Kotlin while a plugin still applies KGP
does not migrate the plugin.

- [Plugin versions and changelog](https://pub.dev/packages/flutter_web_auth_2/changelog)
- [Flutter Built-in Kotlin migration](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers)
