// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auto_route/auto_route.dart' as _i3;
import 'package:settings_presentation/src/appearance/pages/preferences_page.dart'
    as _i1;
import 'package:settings_presentation/src/navigation/pages/settings_page.dart'
    as _i2;

/// generated route for
/// [_i1.PreferencesPage]
class PreferencesRoute extends _i3.PageRouteInfo<void> {
  const PreferencesRoute({List<_i3.PageRouteInfo>? children})
    : super(PreferencesRoute.name, initialChildren: children);

  static const String name = 'PreferencesRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i1.PreferencesPage();
    },
  );
}

/// generated route for
/// [_i2.SettingsPage]
class SettingsRoute extends _i3.PageRouteInfo<void> {
  const SettingsRoute({List<_i3.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i2.SettingsPage();
    },
  );
}
