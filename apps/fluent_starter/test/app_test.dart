import 'dart:async';

import 'package:auth_presentation/auth_presentation.dart';
import 'package:core_testing/core_testing.dart';
import 'package:fluent_starter/app.dart';
import 'package:fluent_starter/config/app_config.dart';
import 'package:fluent_starter/di/injection.dart';
import 'package:fluent_starter/routing/app_router.dart';
import 'package:fluent_starter/routing/app_router.gr.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:home_presentation/home_presentation.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:settings_presentation/settings_presentation.dart';

import 'support/extended_settings_router.dart';

void main() {
  late GetIt container;
  late AppRouter router;
  setUp(() => container = GetIt.asNewInstance());
  tearDown(() => container.reset());
  Future<void> mount(
    WidgetTester tester, {
    SettingsRouter? settingsRouter,
  }) async {
    container = await configureDependencies(
      AppConfig.parse(flavor: 'dev', backend: 'demo'),
      credentials: FakeCredentialStore(),
      preferences: FakePreferenceStore(),
    );
    if (settingsRouter != null) {
      await container.unregister<SettingsRouter>();
      container.registerSingleton<SettingsRouter>(settingsRouter);
    }
    router = container<AppRouter>();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [BlocProvider.value(value: container<AppearanceBloc>())],
        child: FluentStarterApp(routerConfig: router.config()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> signIn(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(const Key('login_email')),
      'demo@example.com',
    );
    await tester.enterText(find.byKey(const Key('login_password')), 'Demo123!');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  testWidgets('login, logout and fresh login replace the protected stack', (
    tester,
  ) async {
    await mount(tester);
    expect(find.text('Sign in'), findsOneWidget);
    final firstLogin = tester
        .element(find.byKey(const Key('login_email')))
        .read<LoginBloc>();
    await signIn(tester);
    expect(find.text('Welcome, Alex Morgan'), findsOneWidget);
    expect(firstLogin.isClosed, isTrue);
    final firstHome = tester
        .element(find.byKey(const Key('logout')))
        .read<HomeBloc>();
    await tester.tap(find.byKey(const Key('logout')));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    expect(router.stack.length, 1);
    expect(container<GetCurrentSession>()().user, isNull);
    expect(
      find.text('Welcome, Alex Morgan', skipOffstage: false),
      findsNothing,
    );
    // Dart's completed cancellation future can belong to the real async zone.
    await tester.runAsync(() async {});
    await tester.pump();
    expect(firstHome.isClosed, isTrue);
    final secondLogin = tester
        .element(find.byKey(const Key('login_email')))
        .read<LoginBloc>();
    expect(secondLogin, isNot(same(firstLogin)));
    expect(secondLogin.state.email.value, isEmpty);
    await signIn(tester);
    expect(find.text('Welcome, Alex Morgan'), findsOneWidget);
    expect(router.stack.length, 1);
    expect(secondLogin.isClosed, isTrue);
    final secondHome = tester
        .element(find.byKey(const Key('logout')))
        .read<HomeBloc>();
    expect(secondHome, isNot(same(firstHome)));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final provider in ['google', 'github']) {
    testWidgets(
      '$provider demo signs in through the feature route and logs out',
      (tester) async {
        await mount(tester);
        final button = find.byKey(Key('login_$provider'));
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(
          container<GetCurrentSession>()().user?.email,
          '$provider@example.com',
        );
        expect(router.currentUrl, '/home');
        expect(find.byKey(const Key('login_email')), findsNothing);
        await tester.tap(find.byKey(const Key('logout')));
        await tester.pumpAndSettle();
        expect(router.currentUrl, '/login');
        expect(find.byKey(Key('login_$provider')), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
  testWidgets('home consumes identity use cases and shows check results', (
    tester,
  ) async {
    await mount(tester);
    await signIn(tester);
    await tester.tap(find.text('Check session'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Your session is up to date.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('logout clears a nested destination before the next login', (
    tester,
  ) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue =
        '/home/preferences';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );
    await mount(tester);
    await signIn(tester);
    expect(router.currentUrl, '/home/preferences');
    await container<Logout>()();
    await tester.pumpAndSettle();
    expect(router.currentUrl, '/login');
    await signIn(tester);
    expect(router.currentUrl, '/home');
    expect(find.text('Welcome, Alex Morgan'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('protected nested route is restored after login', (tester) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue =
        '/home/preferences';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );
    await mount(tester);
    await signIn(tester);
    expect(find.text('Appearance'), findsOneWidget);
    expect(router.currentUrl, '/home/preferences');
    expect(router.topRoute.name, PreferencesRoute.name);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('Fluent menu, typed routes and back share nested route state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await mount(tester);
    await signIn(tester);
    expect(router.currentUrl, '/home');
    await tester.tap(find.text('Preferences'));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);
    expect(router.currentUrl, '/home/preferences');
    expect(await router.maybePopTop(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Alex Morgan'), findsOneWidget);
    expect(router.currentUrl, '/home');
    unawaited(
      router.navigate(
        const AppShellRoute(
          children: [
            SettingsRoute(children: [PreferencesRoute()]),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);
    expect(router.currentUrl, '/home/preferences');
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('expired session removes the protected page', (tester) async {
    await mount(tester);
    await signIn(tester);
    await tester.tap(find.text('Expire demo session'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    expect(router.stack.length, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('a feature can add an internal page without changing app tabs', (
    tester,
  ) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue =
        '/home/preferences/details';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );
    await mount(tester, settingsRouter: ExtendedSettingsRouter());
    expect(find.text('Sign in'), findsOneWidget);
    await signIn(tester);
    expect(find.text('Feature details'), findsOneWidget);
    expect(router.currentUrl, '/home/preferences/details');
    expect(await router.maybePopTop(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);
    expect(router.currentUrl, '/home/preferences');
    expect(await router.maybePopTop(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Alex Morgan'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('appearance selection dispatches an event and updates the app', (
    tester,
  ) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue =
        '/home/preferences';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );
    await mount(tester);
    await signIn(tester);
    await tester.tap(find.byKey(const Key('appearance_theme')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();
    expect(container<AppearanceBloc>().state.mode, ThemeMode.dark);
    expect(
      tester.widget<FluentApp>(find.byType(FluentApp)).themeMode,
      ThemeMode.dark,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('compact login supports large text and exposes validation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    tester.binding.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
    );
    await mount(tester);
    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Use at least 8 characters.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  test('theme persists through a fresh dependency container', () async {
    final preferences = FakePreferenceStore();
    final config = AppConfig.parse(flavor: 'dev', backend: 'demo');
    final first = await configureDependencies(
      config,
      credentials: FakeCredentialStore(),
      preferences: preferences,
    );
    addTearDown(first.reset);
    final appearance = first<AppearanceBloc>();
    final saved = appearance.stream.firstWhere(
      (state) => state.mode == ThemeMode.dark && !state.saving,
    );
    appearance.add(const AppearanceThemeSelected(ThemeMode.dark));
    await saved;
    final second = await configureDependencies(
      config,
      credentials: FakeCredentialStore(),
      preferences: preferences,
    );
    addTearDown(second.reset);
    expect(second<AppearanceBloc>().state.mode, ThemeMode.dark);
  });
}
