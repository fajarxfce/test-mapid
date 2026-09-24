import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:settings_presentation/src/navigation/settings_router.gr.dart';

/// Settings owns its subtree; the app chooses where to mount it.
@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class SettingsRouter {
  List<AutoRoute> get routes => [
    AutoRoute(
      page: SettingsRoute.page,
      path: 'preferences',
      children: [AutoRoute(page: PreferencesRoute.page, path: '')],
    ),
  ];
}
