# Validation record

Latest validation on Linux on 2026-09-24 using Flutter 3.47.5 and Dart 3.13.4.

## Editor and Melos maintenance tasks

- Added `pub:get`, `app:clean`, `app:refresh` and `android:reset` scripts with matching VS Code/Zed task entries. Locked dependency resolution and Flutter cleaning target `apps/fluent_starter`. Android reset uses one standalone Dart script to stop Gradle, clean app output, preserve the project cache in an ignored backup, and restore locked dependencies.
- Executed `pub:get`, `app:refresh` and `android:reset` through Melos successfully. Refresh ran clean before pub get; reset stopped the daemon and backed up `android/.gradle`. The workspace lockfile and generated Dart sources remained unchanged. A dev debug APK build after reset passed in 62.6 seconds on the VPS.
- The full workspace quality gate passed formatting, dependency policy, architecture checks, analysis and **212 tests**. Five new CLI tests exercise a checkout path containing spaces from an unrelated working directory, successful backup, fail-fast behavior on Gradle/Flutter cleanup errors, retained backups on dependency-resolution failure, and an absent Gradle cache. These tests use fake executables and no workspace package resolution.
- Parsed both task configurations: all 28 VS Code and 59 Zed task labels are unique; maintenance commands and working directories match their intended targets. Editor UI interaction and native Windows execution were not exercised. The laptop's original build failure still needs verification in its own checkout; the reset does not migrate the existing legacy KGP plugin.

## Android incremental output recovery

- Investigated a reported `:jni:bundleLibRuntimeToDirDebug` failure where `JniPlugin.class` already existed for a `NEW` incremental change. The reported `/home/fajar/Documents/flutter-gg/flutter-starter` checkout is not present on this host. The error did not reproduce in the VPS checkout; an initial dev debug APK build passed with the existing configuration.
- Verified the documented recovery sequence on the VPS: stopped the Gradle daemon, ran `flutter clean` inside `apps/fluent_starter`, moved the app's project-local `android/.gradle` cache to a temporary backup, and ran `flutter pub get --enforce-lockfile`. The dependency lockfile remained unchanged. The clean dev debug APK build passed, followed by another successful incremental build without cleanup.
- Checked the public plugin metadata and changelog: stable `flutter_web_auth_2` remains at 5.1.0 and still applies legacy KGP; Built-in Kotlin migration is available in 6.0.0 alpha releases. The KGP warning remains expected and is independent of the reported class-copy failure. No dependency or functional Gradle setting was changed; compatibility comments and `docs/android-builds.md` document the current state.
- No application source changed, so the passing 207-test workspace suite was not repeated. The failing machine's local cache still needs the documented recovery; its original error cannot be claimed resolved by the VPS build results.

## Reusable Fluent design system

- Added a catalog of **35 `AppXxx` widgets**, each in its own file, covering typography, actions, form fields, typed selection, date/time pickers, layout, display, feedback and dialogs. The package remains independent of feature/domain code, Bloc, DI and navigation. Components render values and callbacks while Fluent owns native focus/editing/animation behavior.
- Migrated login, home, preferences and shell text to the shared components. Replaced the old page/card/brand/environment widget names. Central tokens, theme resources, accessible labels, validation announcements, loading suppression and responsive text wrapping live in the design system.
- The full workspace quality gate passed formatting, centralized dependency policy, architecture boundaries, analyzer and **207 tests**. The 18 design-system tests include keyboard/mouse behavior, controlled values, text persistence across rebuilds, password visibility, disabled dropdown choices, progress semantics, contrast-sensitive theme foregrounds, and the component catalog at 320/1280 logical pixels with 200% text in both themes. Dialog actions also passed the compact layout check.
- Web release build passed, including Flutter's Wasm compilation dry run. Linux native integration passed all **three** methods (password, Google demo, GitHub demo), including secure-store restoration with a fresh DI container and logout using the migrated UI.
- No dependency, generated-code or platform configuration changes were required. Android and Apple/Windows native builds were not repeated for this component work. Component APIs and usage are documented in `docs/design-system.md`.

## API service and remote datasource separation

- Moved the Retrofit contract and generated HTTP implementation to `src/services/auth_api.dart` and `auth_api.g.dart`. `AuthRemoteDataSource` is a plain interface without Retrofit annotations or Dio types; `ApiAuthRemoteDataSource` implements it using `AuthApi`. Browser OAuth uses the same API service for code exchange, and the repository depends on datasource contracts.
- Regenerated Injectable and Retrofit output. The generated HTTP implementation differs from the previous version only in class and part names. The named `mainApi` binding, endpoint behavior and session handling remain covered by the existing integration-style repository and DI tests.
- The complete workspace quality gate passed formatting, dependency policy, architecture boundaries, analyzer and **191 tests**. No new dependencies or platform configuration were required. Native integrations and platform builds were not repeated for this boundary correction.

## Identity session and datasource boundaries

- Removed the stateful `AuthLocalDataSource`. Local credential I/O uses the existing `CredentialStore` contract and platform implementations. `AuthRemoteDataSource` is the generated Retrofit contract; browser OAuth has a separate contract and implementation.
- Repositories select datasource operations, map DTOs and delegate session operations. `PersistentIdentitySession` owns observation, restoration, credential commits and logout. `BehaviorSubject`, `CancelableOperation` and `Lock` replace the handwritten replay stream, public revision protocol and write queue. Provider availability/admission remains in the domain use case.
- The named `AuthInterceptor` reads credentials through `HttpAuthentication`, rejects protected requests with missing credentials, and reports protected HTTP `401` responses to the session owner. Public requests and other origins cannot expire the session. The identity micro-package binds both session and HTTP contracts to the same storage-backed instance without a Dio/repository dependency cycle.
- The full workspace quality gate passed formatting, centralized dependency policy, architecture boundaries, analyzer and **191 tests**. Regressions cover concurrent writes, superseded restores, logout/disposal during persistence, failed cleanup, provider admission while a cancelled browser attempt is still open, protected versus public `401`, and an old request's `401` arriving after a newer login with identical token text.
- Regeneration passed in dependency order; all **19 generated Dart files** retained identical hashes. Injectable and Retrofit output is committed alongside the source contracts.
- Linux native integration passed all **three** methods (password, Google demo, GitHub demo), including secure-store restoration through a fresh DI container and logout. The web release build passed, including Flutter's Wasm dry run.

No refresh-token backend contract exists: a protected `401` expires the current session without attempting refresh or replay. OAuth providers remain simulated until a backend is configured. Android and Apple/Windows native builds were not repeated for this refactor.

## Provider sign-in

- Added Google/GitHub support through a system-browser OAuth broker contract: random state, S256 PKCE, strict callback validation, a Retrofit application-code exchange, and the same session persistence used by password login. Live API providers require explicit configuration; no OAuth backend or provider credentials are included. `docs/oauth.md` specifies the backend and platform setup.
- Provider availability and overlapping-authorization policy live in the pure `LoginWithProvider` use case, shared by the identity Injectable micro-package. The repository only coordinates fetching and session persistence; the LoginBloc owns loading and presentation state. Tests verify that multiple callers share the policy and rejected requests never reach the repository.
- The final workspace quality gate passed formatting, centralized dependency policy, architecture boundaries, analyzer, and **177 tests**. Coverage includes callback/state tampering, duplicate parameters, one-time codes, PKCE mismatch, provider mismatch, cancellation/retry, logout during an outstanding browser attempt, storage failures, provider UI, and DI lifetimes.
- Re-ran all builders in dependency order: all **19 generated Dart files** retained identical hashes after formatting. Injectable, Freezed, JSON and AutoRoute output is committed.
- Web release build passed, including Flutter's Wasm compilation dry run. The static callback bridge passed checks for same-origin delivery, history cleanup, and a missing opener. CLI checks verified OAuth flag forwarding and rejection of incomplete configuration. The merged Android manifest contains the application-specific callback activity/scheme.
- Native integration passed all three methods (password, Google demo, GitHub demo), including secure-store restore through a fresh DI container and logout, on Linux under Xvfb with an isolated keyring and on the physical Android 16 phone over WireGuard. After moving authorization policy into the use case, the workspace suite and Linux integration passed again.
- Android debug APK builds passed with `flutter_web_auth_2` 5.1.0. Flutter reports that this stable plugin still applies the Kotlin Gradle Plugin; the project's existing legacy Kotlin/DSL compatibility flags remain required. Linux builds need WebKitGTK 4.1 development libraries through the plugin's desktop dependency, even when using an external browser; local dependencies and CI are configured.
- During the physical test installation, Android rejected an existing dev app signed with a different debug key. Flutter automatically uninstalled/reinstalled that dev app, resetting its local data. This side effect was reported to the user.

The provider flows exercised here are simulated. Real Google/GitHub browser callbacks, server-side provider verification, and production credentials remain untested until an OAuth backend exists. Apple and Windows native builds were not run on this Linux host.

## Shared identity ownership

- Moved auth's domain/data packages into `packages/core/identity`, with pure domain session snapshots, current-session and observation use cases, and a replaying session stream owned by the local data source. Auth and home depend on the shared domain API.
- Removed `SessionBloc`, `HomeSession`, and `AppHomeSession`. Home owns its operation loading/feedback; router and guard consume domain session use cases, and bootstrap restores the session once. Injectable registrations remain inside the identity micro-package.
- The workspace quality gate passed: formatting, dependency policy, architecture boundaries, analyzer, and all 155 tests. Coverage includes new subscribers receiving the current session, independent observer disposal, two Blocs sharing identity without sharing loading/feedback, credential write races, login/logout/expiry, guarded deep links, and feature router isolation.
- Regenerated affected Injectable, Freezed, and AutoRoute output. No hosted dependency versions changed. Platform builds are deferred to the subsequent OAuth integration in this task.

## Physical Android debugging over WireGuard

- Enabled classic ADB TCP on port `5555` through the laptop's authorized USB connection. The VPS then connected directly to the phone's WireGuard address, `10.77.77.3:5555`, with device authorization. Flutter detected a physical SM A725F running Android 16 / API 36.
- Added dev/staging/prod `Android via WireGuard` debug presets in both editors. All 26 Zed and 22 VS Code configurations passed their debugger schemas; all six new presets have aligned device IDs, flavors, and demo backend flags. The fixed-port setup and reconnection after a phone reboot are documented in `android-remote.md`.
- Launched the actual Zed Android/WireGuard dev configuration through Flutter DAP on the VPS. Build, installation on the phone, VM-service connection, a breakpoint in `main.dart`, stack inspection, continue, hot reload, and debugger disconnect passed. The test session was stopped; the phone's ADB connection remains available for the user's editor session.

The debugger protocol and physical device were exercised directly; interaction with the Zed/VS Code UI was not automated. No application source or dependency versions changed, so the Dart test suite was not repeated for these presets.

## Android remote debugging

- Added dev/staging/prod tunnel debug presets to both editors, targeting the VPS's `127.0.0.1:15555` ADB transport. Documented Android Wireless debugging through a laptop SSH tunnel, distinct pairing/connection ports, reconnecting, and direct WireGuard access when the phone itself is reachable through the VPN.
- Parsed all seven editor JSON files. All 23 Zed and 19 VS Code launch/attach configurations passed their debugger schemas; the six new presets have matching flavors, device IDs, demo backend flags, and valid program paths. OpenSSH's configuration-only `ssh -G` check confirmed the documented loopback forwards and connection options.
- `dart run tool/app.dart build android dev --smoke`: passed. APK metadata confirms `dev.example.fluentstarter.dev`, a debuggable build, minimum SDK 24, and target SDK 36. The build emitted an Android SDK XML-version warning but completed successfully. Generated sources and dependency lockfiles remained unchanged.

At the initial SSH-tunnel setup, no Android phone was connected to ADB on the VPS. The SSH tunnel and Wireless debugging pairing workflow remain unverified on a physical phone; the later fixed-port WireGuard validation is recorded above. This configuration/documentation change did not rerun the Dart test suite; its latest full result is recorded below.

## Editor workflows

- Android now has explicit dev/staging/prod debug presets and `Android: Run`, `Android: Build APK debug`, and `Android: Build APK release` tasks in both editors. VS Code prompts for a device ID; Zed's Android debug preset targets a running emulator using the `emulator-` ID prefix, which can be replaced with a physical device's ID. Run tasks select a single connected Android device through the existing app command.
- Revalidated both debugger schemas, input references, and Android task/flavor arguments after exposing these presets. The full workspace check passed again with all 155 tests. Only Linux was connected, so Android launches and APK builds were not exercised for this configuration change.
- Added VS Code launch/task settings and extension recommendations, plus Zed debugger/task/settings files. Both editors use workspace-relative paths and the existing app/Melos commands. Flavor presets retain the explicit demo backend; VS Code also prompts for API launch/build/run configuration.
- Parsed all seven editor JSON files and validated launch configurations against Dart Code's debugger schemas and the Zed Dart extension 0.4.1 schema. Checked program/cwd paths, input references, flavor alignment, task arguments, and explicit profile/release flags for Zed's Flutter DAP.
- Executed the command from VS Code's `Workspace: Check` task: all 155 tests, analyzer, formatting, and architecture/dependency checks passed.
- Launched the actual Zed Linux/dev configuration through Flutter DAP under Xvfb with an isolated keyring. A breakpoint in `main.dart`, stack inspection, continue, hot reload, and disconnect passed.
- Executed the command from VS Code's smoke-build task with web/dev inputs: release build and Wasm dry run passed.

VS Code and Zed executables were unavailable in this environment, so editor UI interactions were not exercised. Android, iOS, macOS, and Windows launch/build presets were checked as configuration, without running their native toolchains.

## Feature-owned navigation

- Auth, home, and settings now own their `@RoutePage` pages, route trees, and generated route classes. The app generates only `AppShellRoute` and composes the feature trees with its session guard. Feature router configuration classes use `@AutoRouterConfig` without creating additional `RootStackRouter` instances.
- Home and settings expose one tab entry each, backed by an internal `AutoRouter` stack. A test fixture adds a deeper settings page without changing app routes or tab declarations; a guarded deep link reaches it after login, and back returns through preferences to overview.
- Feature router bindings resolve factory Blocs through their injected container. Tests verify fresh login/home Blocs after logout and disposal when their routes leave the widget tree. Home consumes its own session contract, adapted from auth in app composition; its generated subtree also mounts in a host without app/auth dependencies.
- `flutter pub get --enforce-lockfile`: passed; resolved versions and the root lockfile are unchanged.
- `dart run melos run check --no-select`: passed with 155 tests, clean analysis, formatting, dependency policy, and architecture checks. Coverage includes typed navigation, guarded deep links, logout/expiry, session feedback, feature isolation, Bloc lifetimes, and restrictions on feature service-locator access.
- Melos generation passed; all 19 generated source files remained byte-for-byte unchanged on regeneration, including the three feature routers and the new home Injectable module.
- Web dev release build passed, including the Wasm dry run.
- `bash tool/test_linux.sh`: dev debug build and native integration passed with an isolated OS keyring, exercising login, restore through a fresh dependency container, and logout.

Android, Windows, iOS, and macOS builds were not repeated for this navigation refactor.

## Presentation grouped by feature

- Presentation implementation stays under `lib/src/`: auth groups login and session, settings groups appearance, and home groups its pages/widgets. Bloc, event, and state files sit together in each feature's `bloc/`; login inputs/pages and presentation tests follow the same feature grouping.
- Each event family now occupies one file. The architecture checker permits a sealed root and its direct variants together while still rejecting unrelated public types. UI checks cover nested feature pages/widgets, and presentation sources outside `src` are rejected except for the package barrel and `lib/di`.
- All five Injectable micro-packages now place their entry points and generated modules in `lib/di`. Package exports and generated imports resolve their new locations.
- `dart run melos run check --no-select`: passed with 144 tests, clean analysis, formatting, dependency policy, and architecture checks. Existing Bloc, generated DI, and router/widget behavior passed; new regressions cover the sealed-family exception, UI rules at nested paths, and mandatory presentation `src` layout.
- Melos generation passed; all 14 generated source files remained byte-for-byte unchanged on regeneration at their final locations.
- Web dev release build passed, including the Wasm dry run.

Native builds and integration were not repeated for this source-layout change; earlier results are recorded below.

## Network resources and local auth sessions

- Added the public `networkBoundResource` fetch-and-commit function. Remote/decoding failures skip persistence; successful results wait for the local commit, and storage failures retain their original classification.
- Auth's repository now composes remote and local data sources. An explicit `AuthSession` model and mapper replace the anonymous login record and inline token validation. The local data source owns session state, credential access, revision checks, ordered writes/rollback, notifications, and generated disposal.
- `dart run melos run check --no-select`: passed with 139 tests, clean analysis, formatting, dependency policy, and architecture checks. Coverage includes resource commit ordering, rejected persistence after remote/decoding errors, whitespace-only tokens, overlapping session writes, queued logout followed by a new login, queue recovery after storage failure, and disposal during an unfinished write.
- Existing auth, Bloc, routing, and widget regressions passed. Logout clears memory immediately and waits for credential cleanup; disposed local sources drain pending rollback. Idle queues release their completed futures, allowing widget-test containers to dispose outside the widget scheduler.
- Melos generation passed, including the local data source's Injectable registration/disposer. All 14 generated source files remained byte-for-byte unchanged on regeneration.
- `bash tool/test_linux.sh`: dev debug build and native integration passed with an isolated OS keyring, exercising login, restore through a fresh dependency container, and logout.
- Web dev release build passed, including the Wasm dry run.

## Named Dio clients

- Removed `NetworkConfig`. App bindings now supply `BaseOptions`, the transport adapter, and a logging interceptor under `@Named(mainApi)`. Core/network constructs the named Dio and credential interceptor. Retrofit auth and the demo-session repository explicitly select that client.
- Credential and logging interceptors accept their dependencies directly and can be constructed separately for each backend. The app configures one production client; regression fixtures add a second named client with a different origin, timeout, credential store, and logger.
- `dart run melos run check --no-select`: passed with 131 tests, clean analysis, formatting, dependency policy, and architecture checks. Tests verify separate client configuration, origin-restricted credentials, independent logging, use of the public safe-call function with either client, and independent disposal. Auth's generated module still performs login/restore/expiry/logout when unrelated named and unnamed Dio instances are registered.
- Melos generation passed. All 14 generated source files remained byte-for-byte unchanged on a second run, matching CI's regeneration check.
- Web dev release build passed, including Flutter's Wasm dry run.

Native builds and integration were not repeated for this DI refactor; earlier results are recorded below.

## Public safe API function

- Replaced the injected `SafeApiCall` class with the public `safeApiCall` function. Removed retry/backoff orchestration, helper-managed cancellation, `NetworkConfig.onFailure`, and the unused direct HTTP-date parser dependency. Each callback runs once; cancellation is passed directly to Dio/Retrofit.
- `dart run melos run check --no-select`: passed with 130 tests, clean analysis, formatting, dependency policy, and architecture checks. Removed tests for the deleted retry/observer API; retained all Dio/HTTP/native exception mapping and auth regressions. Real Dio tests cover pre-cancelled requests, cancellation reaching transport, and late adapter errors.
- `flutter pub get --enforce-lockfile`: passed; all resolved versions remain unchanged. `http_parser` remains a transitive dependency.
- Melos generation passed and removed the helper from both the network and auth dependency graphs.

Platform builds and native integration were not repeated for this function refactor. The records below describe earlier implementations.

## Automatic Dio failure mapping

- Normal calls now use `safeApiCall(() => request())`. Cancellation remains optional; repository callbacks no longer receive or create a token by default.
- The mapper exhaustively handles all nine `DioExceptionType` values in the installed Dio 5.11.1, including the previously missed `transformTimeout`. Certificate/TLS errors map to `security`; remaining HTTP 4xx statuses have a `request` fallback, all 5xx statuses map to `server`, and invalid/rejected response shapes map to `invalidResponse`.
- Unknown/connection exceptions inspect nested causes, including native socket/DNS, HTTP I/O, OS and TLS exceptions. Cycle/depth guards keep custom exception wrappers bounded. Explicit timeout/cancellation/certificate types take precedence over attached HTTP metadata. TLS/storage causes are excluded from read retries.
- `dart run melos run check --no-select`: passed with 147 tests, clean analysis, formatting, dependency policy, and architecture checks. Tests compare coverage against `DioExceptionType.values`, exercise every 4xx/5xx status, nested causes, native exception types, and existing app flows.
- `flutter pub get --enforce-lockfile`: passed. The central Dio minimum now matches the already installed 5.11.1; all 173 resolved dependency versions are unchanged.
- Melos generation passed and left all 14 generated source files unchanged.
- Web dev release build passed, including the Wasm dry run, verifying that conditional exception mapping keeps native I/O APIs out of the web build.

Native builds/integration were not repeated for this mapper and callback refactor; native exception mapping ran in Dart VM tests. Earlier native integration results are below.

## Safe API calls and storage boundaries

- Added injected `SafeApiCall`, opt-in `ApiRetryPolicy.readOnly`, typed HTTP/decoding/cancellation failures, and an optional final-failure observer with stack traces. `safeStorageCall` and `Result.flatMap` remove repeated exception handling from auth/settings repositories.
- `dart run melos run check --no-select`: passed with 136 tests, clean analysis, formatting, dependency policy, and architecture checks.
- Core tests cover synchronous/asynchronous/nullable/void results; HTTP categories; JSON/type errors; final-failure reporting; retry limits, exponential jitter and Retry-After seconds/dates; mutation exclusion; cancellation before execution, during Dio I/O, and during backoff; late errors; and storage short-circuiting.
- Auth regression tests cover malformed/empty login responses, failed credential reads (including the interceptor), failed cleanup after 401, preserved credentials on timeout, stale 401 after a newer login, and logout during an unfinished credential write. Existing feature DI, Bloc, routing, and appearance tests also passed.
- `flutter pub get --enforce-lockfile`: passed. The HTTP-date parser now has a central constraint; all 173 resolved package versions remain unchanged.
- `dart run melos run generate --no-select`: passed; all 14 generated source files remained byte-for-byte identical on regeneration, including Retrofit cancellation forwarding and Injectable registrations.
- Web dev release build: passed, including the Wasm dry run.
- `bash tool/test_linux.sh`: dev debug build and native integration passed. Login stored credentials in the isolated OS keyring, a fresh container restored the session, and logout cleared it.

Android, Windows, iOS, and macOS builds were not repeated for this change.

## Feature-owned use-case registration

- Auth and settings use-case bindings now live in their data packages' `injection.dart`, collected by the existing generated micro-package modules. App DI supplies runtime configuration and composes these modules; it no longer imports either domain package.
- `flutter pub get --enforce-lockfile`: passed. Auth domain is now an app test dependency; the app's unused settings domain dependency was removed. No resolved versions changed.
- `dart run melos run check --no-select`: passed with 90 tests, clean analysis, formatting, dependency policy, and architecture checks.
- New package tests initialize generated feature modules without app DI. Auth exercises all five use cases through login, session observation, restore, expiry, and logout; settings exercises theme loading and persistence. Both verify use-case factory lifetimes.
- Existing app tests still cover bootstrap, generated route/Bloc composition, deep links, login/logout, session expiry, and appearance persistence.
- `dart run melos run generate --no-select`: passed; all 14 generated files stayed byte-for-byte identical on regeneration.

Platform builds and native integration were not repeated for this registration refactor. Their latest results are recorded below.

## Shared versions, consolidated DI, and Bloc enforcement

- Root `pubspec_overrides.yaml` owns 29 hosted dependency constraints. All 14 pubspecs use `any` for hosted/workspace dependencies and retain SDK declarations. All 173 resolved dependency versions are unchanged.
- `flutter pub get --enforce-lockfile` and `dart run melos bootstrap`: passed for all 13 workspace members.
- Each of the five Injectable micro-packages has one `injection.dart` entry point. App bindings are consolidated in app `di/injection.dart`; the Retrofit factory is directly annotated. Network configuration, provider lifetimes, and disposal remain covered by existing graph/network tests.
- `dart run melos run check --no-select`: passed with 88 tests, clean analysis, formatting, dependency policy, and architecture checks.
- Dependency-policy regression tests reject scattered versions, missing central constraints, member overrides, and overridden workspace/SDK sources. Bloc checks reject legacy state APIs across handwritten production files, including aliases, prefixed constructors, mixins, and tear-offs outside UI folders.
- `dart run melos run generate --no-select`: passed; all 14 generated source files stayed byte-for-byte identical on regeneration.
- Web dev release build: passed, including the Wasm dry run.
- `bash tool/test_linux.sh`: dev debug build and native integration passed. Login persisted credentials to the isolated OS keyring, a new container restored the session, and logout cleared it.

Android, Windows, iOS, and macOS builds were not repeated for this change.

## UI state and event boundaries

- Removed `AppServices`, `AppScope`, and the application-services factory. UI consumes Bloc state and dispatches events; route composition resolves `LoginBloc` directly from Injectable.
- `dart run melos run check --no-select`: passed with 68 tests, clean analysis, formatting, and architecture checks.
- UI architecture regression tests reject helper methods, async work, imperative decisions, mutation, subscriptions, and domain/data/DI imports. The checker normalizes paths for Windows and POSIX; its 14 tests passed after that adjustment.
- Session Bloc tests cover startup failure, session observation, checking/loading feedback, demo expiry, and logout storage failure. Settings tests cover persisted/unknown themes, storage failures, and ordered writes after rapid selections.
- Widget tests cover guarded deep links, login/logout/login with a fresh route Bloc, session expiry, nested route/back behavior, and changing appearance through an event. Widget-test containers are created inside the test's fake-async zone so stream callbacks and UI frames use the same scheduler.
- `dart run melos run generate --no-select`: passed; all 14 generated source files remained byte-for-byte identical on regeneration.
- Web dev release build: passed, including the Wasm dry run.
- `bash tool/test_linux.sh`: dev debug build and native integration passed. Login persisted credentials to the isolated OS keyring, the first container was disposed, a new container restored the session, and logout cleared it.
- Appearance Bloc tests also passed after enabling the package's required Material icon assets.

Android, Windows, iOS, and macOS builds were not repeated for this change. The workspace now contains 13 packages.

## Modular Injectable, Bloc, and generated navigation

- `dart run melos run check --no-select`: passed, including formatting, strict architecture rules, analyzer, and 51 tests.
- Generated DI graph tests resolve Dio, Retrofit, remote data source, repository, use cases, Bloc, guard, and router; exercise login/restore/logout; verify factory/singleton lifetimes and repository disposal.
- Network tests verify provider configuration, origin-scoped credentials, login header omission, redacted logs, and generated Dio transport disposal. Real backend mode selects the platform adapter without a demo fallback; no live backend was contacted.
- Bloc tests cover validation, successful submission, duplicate submit suppression, ignored edits during submission, and retry after failure.
- Router widget tests cover protected nested deep links, generated typed navigation, Fluent menu/URL synchronization, back to Overview, logout, and session expiry.
- `dart run melos run generate --no-select`: passed; a second run left all 10 generated source files byte-for-byte unchanged.
- `dart run tool/app.dart build web dev --smoke`: release build passed, including Flutter's Wasm dry run.
- `bash tool/test_linux.sh`: dev debug build and native integration passed under Xvfb with an isolated Secret Service. Login persisted real secure credentials, a new service container restored the session, and logout cleared it.

Android, Windows, iOS, and macOS builds were not repeated for this change.

## File organization refactor

- `dart run melos run check --no-select`: passed, including format, analyzer, architecture rules, and 41 tests.
- Package barrels and one-public-type-per-file rules include regression coverage.
- JSON, Retrofit, Freezed, DI, and route code regenerated successfully; a second generation left all seven generated Dart files unchanged.
- Web dev release build: passed after the refactor.

The native build and integration results below describe the initial scaffold; native builds were not repeated for this source-organization refactor.

## Initial scaffold

- Workspace bootstrap with enforced root lockfile: passed; 10 workspace packages resolved.
- `dart run melos run check --no-select`: passed, including format, architecture boundaries, analyzer, and 38 tests.
- Build runner regeneration: passed; committed Dart generated files unchanged.
- GitHub Actions workflow validation with actionlint 1.7.12: passed.
- Android dev/prod debug APK builds: passed.
- Web dev/prod release builds: passed. The final prod build includes all required icon fonts.
- Linux dev/prod release builds: passed.
- Native Linux integration: login, actual secure credential persistence, restore through a fresh service container, and logout passed under Xvfb with an isolated Secret Service.
- Apple scheme checks for all three flavors: passed, including preserved Flutter preparation and build actions.

Windows, iOS, and macOS native builds were not executed on this Linux host. GitHub Actions contains their build jobs on appropriate runners, alongside all dev/staging/prod combinations. Remote CI was not run as part of this local validation.

Build artifacts are ignored. Android APKs are under `apps/fluent_starter/build/app/outputs/flutter-apk/`, Linux bundles under `apps/fluent_starter/build/linux/x64/<flavor>/release/bundle/`, and the latest web build under `apps/fluent_starter/build/web/`.
