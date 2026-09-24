# VS Code and Zed

Open the **repository root**, not only `apps/fluent_starter`. Both editors use Flutter/Dart from `PATH`; no personal SDK path is committed. Run `Workspace: Pub get (locked)` or `Workspace: Bootstrap` after cloning.

All flavor presets use the **demo backend**, including `prod` and release builds. Native launches pass both `--flavor` and `FLAVOR`; web launches pass only Dart defines. Build/run tasks use the existing `tool/app.dart` wrapper.

For a project opened over SSH, connect the phone to ADB on the server first. See [Android debugging from a VPS](android-remote.md) for a fixed ADB port over WireGuard, Wireless debugging, and reverse SSH tunnels. Both editors provide `Debug | dev/staging/prod | Android via WireGuard` presets targeting this workspace's phone at `10.77.77.3:5555`, and `Android via SSH tunnel` presets targeting `127.0.0.1:15555` on the server. Change the WireGuard preset's device address when using a different phone or VPN network.

## VS Code

Install the recommended Dart and Flutter extensions when prompted.

| Action | How |
|---|---|
| Debug Android | Select `Debug \| dev/staging/prod \| Android` → F5 → enter the device ID |
| Debug the app | Run and Debug → `Debug \| dev/staging/prod \| native` → F5 |
| Choose a native device | `Flutter: Select Device`, or the device selector in the status bar |
| Debug in Chrome | Select the corresponding `web` launch preset |
| Run without breakpoints | Run → Start Without Debugging (Ctrl+F5 on Windows/Linux) |
| Profile / release | Select `Profile` or `Release`, then choose the flavor |
| Debug against an API | Select `Debug API`, choose the flavor, and enter the HTTPS origin |
| Attach | Select `Attach \| running Flutter VM` and paste its complete VM service URI |
| Debug tests | Select the app/tooling test-suite preset, or use the Dart extension's inline Debug Test action |
| Build | `Tasks: Run Build Task` (Ctrl+Shift+B) selects the smoke build, then asks for platform/flavor |
| Release build / terminal run | `Tasks: Run Task` → the appropriate Flutter task |

Native presets use the selected device. Choose a native device for native configurations; web configurations select Chrome explicitly. Profile/release require a supported device; use debug mode for normal breakpoint work. Dart files format and organize imports on save, and manual saves of changed files trigger Flutter hot reload during a debug session.

The build task defaults to Linux/dev. Smoke builds produce a debug APK on Android, omit signing on Apple targets, and otherwise produce release builds. Choose `Flutter: Build release` for a regular release build. The API build/run tasks request the HTTPS origin explicitly.

Configuration files: `.vscode/launch.json`, `.vscode/tasks.json`, `.vscode/settings.json`, and `.vscode/extensions.json`.

Android has explicit launch presets and `Android: Run`, `Android: Build APK debug`, and `Android: Build APK release` tasks for every flavor. Debug asks for an Android device ID; its default `emulator-` matches one running Android emulator. For a connected phone or multiple emulators, enter the exact ID shown by the `Flutter: Devices` task (`flutter devices`). The Android run tasks automatically select a single connected Android device through the app wrapper.

## Zed

Install the **Dart** extension with debug adapter support. These configurations follow the extension's **0.4.1** schema. Its adapter name is `Dart`, while Flutter launch configurations require `type: flutter`.

- Run `debugger: start` from the command palette and select a flavor/platform. Linux, macOS, Windows, and Chrome presets select their device explicitly.
- Android debug presets are named `Debug | dev/staging/prod | Android emulator`. They pass `-d emulator-`, which targets a running Android emulator without hardcoding its port. Start the emulator first. For a connected Android phone or multiple emulators, replace `emulator-` with the exact ID from the `Flutter: Devices` task (`flutter devices`) in that preset's `toolArgs`; Zed does not provide VS Code's device input prompt.
- Android terminal tasks are grouped under `Android: Run`, `Android: Build APK debug`, and `Android: Build APK release`, with all three flavors. Run tasks select a single connected Android device automatically; build tasks do not need a connected device.
- The generic `native (auto device)` presets remain available for other native targets, including iOS. Add `"-d", "<actual-device-id>"` to `toolArgs` if Flutter cannot select a single device.
- Run `task: spawn` to choose a task. Filter by `Android` or `Flutter`, flavor, and platform. Run/release-build presets cover all six targets and all three flavors; Android debug APK and Apple smoke builds have separate labels.
- The Linux profile/release presets include `--profile`/`--release` in `toolArgs`: Flutter's DAP reads the CLI flags. Changing `flutterMode` alone is insufficient for this adapter.
- For hot reload from a terminal run task, press `r`; press `R` for hot restart and `q` to quit. Zed formats Dart files on save; this configuration does not add a hot-reload-on-save integration to Zed's debugger.

To adjust a task temporarily, select it in the task picker and press Tab to edit its command. For example, add `--device=<id>` for a mobile run, or `--api=https://your-api.example.com` for the API backend. Keep the HTTPS origin free of paths/query parameters.

To debug an API backend in Zed, duplicate the relevant launch entry, replace `--dart-define=BACKEND=demo` with `--dart-define=BACKEND=api`, and add `--dart-define=API_BASE_URL=https://your-api.example.com` to `toolArgs`. Keep the native flavor and `FLAVOR` values identical.

Configuration files: `.zed/debug.json`, `.zed/tasks.json`, and `.zed/settings.json`.

## Workspace tasks

Both editors expose dependency bootstrap, locked pub get, code generation, the complete quality gate, analysis, formatting, all tests, flavor regeneration, device listing, Flutter doctor, and the Linux keyring integration test.

| Maintenance task in either editor | Melos command from the repository root |
|---|---|
| `Workspace: Pub get (locked)` | `dart run melos run pub:get --no-select` |
| `App: Clean` | `dart run melos run app:clean --no-select` |
| `App: Clean + pub get (locked)` | `dart run melos run app:refresh --no-select` |
| `Android: Reset build cache + pub get` | `dart run melos run android:reset --no-select` |

`pub:get` resolves the shared workspace lockfile from `apps/fluent_starter`, so Flutter also refreshes the app's plugin metadata. The editor pub-get task invokes Flutter directly, allowing initial setup before Melos is available. `app:clean` targets Flutter's generated app outputs; Melos's built-in `clean` command removes package metadata and serves a different purpose. `app:refresh` runs clean and locked pub get sequentially.

For the Android JNI incremental-output error, choose the Android reset task: it stops Gradle, cleans the app, backs up its project-local Gradle cache and restores dependencies in order. The editor invokes the dependency-free `tool/reset_android.dart` script directly; Melos wraps the same script. See [Android build recovery](android-builds.md) for backup locations and troubleshooting. Stop active builds/debug sessions before cleaning. Tasks execute where the checkout is open, including on the server for remote workspaces.

Generation is an explicit task; launching the debugger does not regenerate the whole workspace. Use `Workspace: Generate` after changing annotations and `Workspace: Check` before committing. Linux integration requires its Linux host dependencies; Apple and Windows builds require their respective hosts/toolchains. See the platform matrix in [README](../README.md#platforms-and-build-verification).
