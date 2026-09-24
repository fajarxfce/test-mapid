import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:settings_presentation/settings_presentation.dart';

/// Simulates a new feature-owned page while leaving app composition untouched.
class ExtendedSettingsRouter extends SettingsRouter {
  @override
  List<AutoRoute> get routes => [
    for (final route in super.routes)
      route.copyWith(
        children: [
          ...route.children!,
          NamedRouteDef(
            name: 'SettingsDetailsTestRoute',
            path: 'details',
            builder: (_, _) =>
                const ScaffoldPage(content: Text('Feature details')),
          ),
        ],
      ),
  ];
}
