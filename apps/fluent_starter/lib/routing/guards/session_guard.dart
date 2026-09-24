import 'package:auth_presentation/auth_presentation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SessionGuard extends AutoRouteGuard {
  SessionGuard(this._current);
  final GetCurrentSession _current;
  final _pending = <NavigationResolver>[];

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (_current().isAuthenticated) {
      resolver.next();
      return;
    }
    _pending.removeWhere((pending) => pending.isResolved);
    _pending.add(resolver);
    resolver.redirectUntil(const LoginRoute());
  }

  bool resumePendingNavigation() {
    final pending = _pending.where((resolver) => !resolver.isResolved).toList();
    _pending.clear();
    for (final resolver in pending) {
      resolver.resolveNext(true, reevaluateNext: false);
    }
    return pending.isNotEmpty;
  }

  void cancelPendingNavigation() {
    for (final resolver in _pending) {
      if (!resolver.isResolved) resolver.next(false);
    }
    _pending.clear();
  }
}
