# Editor configuration

Open the repository root in VS Code or Zed. Flutter and Dart must be available
on `PATH`. Android builds require JDK 21, selected through `JAVA_HOME`.
Create and populate the root `.env` before launching the application.

## Run and debug

- VS Code: select a `Debug | dev/staging/prod | Android` configuration and press
  F5. The device input accepts an ID from `Flutter: Devices`.
- Zed: run `debugger: start` and select an Android configuration. The emulator
  preset uses `emulator-`; replace it with an exact device ID when necessary.
- Both editors retain WireGuard (`10.77.77.3:5555`) and SSH tunnel
  (`127.0.0.1:15555`) presets, plus web and attach configurations.
- Launch configurations pass `.env` through `--dart-define-from-file`. API keys
  are never stored in the editor configuration.

For remote development, tasks execute on the remote host. See
[Android remote debugging](android-remote.md) for device connectivity.

## Tasks

| Task | Purpose |
|---|---|
| `Workspace: Pub get (locked)` | Restore locked dependencies and app plugin metadata |
| `Workspace: Generate` | Run Injectable, Retrofit, JSON, Freezed and AutoRoute generators |
| `Workspace: Check` | Run formatting, dependency policy, architecture, analysis and tests |
| `App: Clean` | Clean Flutter output in the application directory |
| `App: Clean + pub get (locked)` | Clean output and restore dependencies sequentially |
| `Android: Reset build cache + pub get` | Stop Gradle, clean output, back up project cache and restore dependencies |
| `Android: Run / Build APK debug / Build APK release` | Run or build the selected flavor |

Build tasks use `tool/app.dart`. Debugger launches do not automatically clean
outputs or regenerate source code. Release builds use debug signing for this
case study; distribution signing must be configured before store publication.
