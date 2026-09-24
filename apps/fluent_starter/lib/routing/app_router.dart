import 'dart:async';

import 'package:auth_presentation/auth_presentation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluent_starter/routing/app_router.gr.dart';
import 'package:fluent_starter/routing/guards/session_guard.dart';
import 'package:home_presentation/home_presentation.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart';
import 'package:settings_presentation/settings_presentation.dart';

@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter(
    this.sessionGuard,
    GetCurrentSession current,
    WatchSession watch,
    this._authRouter,
    this._homeRouter,
    this._settingsRouter,
  ) : _authenticated = current().isAuthenticated {
    _subscription = watch().listen(_onSessionChanged);
  }
  final SessionGuard sessionGuard;
  final AuthRouter _authRouter;
  final HomeRouter _homeRouter;
  final SettingsRouter _settingsRouter;
  late final StreamSubscription<Session> _subscription;
  bool _authenticated;

  void _onSessionChanged(Session state) {
    if (_authenticated == state.isAuthenticated) return;
    _authenticated = state.isAuthenticated;
    if (!_authenticated) {
      sessionGuard.cancelPendingNavigation();
      unawaited(replaceAll([const LoginRoute()]));
    } else if (!sessionGuard.resumePendingNavigation()) {
      unawaited(replaceAll([const AppShellRoute()]));
    }
  }

  @disposeMethod
  Future<void> close() async {
    await _subscription.cancel();
    sessionGuard.cancelPendingNavigation();
    super.dispose();
  }

  @override
  List<AutoRoute> get routes => [
    RedirectRoute(path: '/', redirectTo: '/home'),
    ..._authRouter.routes,
    AutoRoute(
      page: AppShellRoute.page,
      path: '/home',
      guards: [sessionGuard],
      children: [..._homeRouter.routes, ..._settingsRouter.routes],
    ),
    RedirectRoute(path: '*', redirectTo: '/home'),
  ];
}
