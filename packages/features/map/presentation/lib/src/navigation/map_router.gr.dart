// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auto_route/auto_route.dart' as _i2;
import 'package:fluent_ui/fluent_ui.dart' as _i3;
import 'package:map_presentation/src/map/pages/map_page.dart' as _i1;

/// generated route for
/// [_i1.MapPage]
class MapRoute extends _i2.PageRouteInfo<MapRouteArgs> {
  MapRoute({
    _i3.Key? key,
    _i3.Widget? canvas,
    List<_i2.PageRouteInfo>? children,
  }) : super(
         MapRoute.name,
         args: MapRouteArgs(key: key, canvas: canvas),
         initialChildren: children,
       );

  static const String name = 'MapRoute';

  static _i2.PageInfo page = _i2.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MapRouteArgs>(
        orElse: () => const MapRouteArgs(),
      );
      return _i1.MapPage(key: args.key, canvas: args.canvas);
    },
  );
}

class MapRouteArgs {
  const MapRouteArgs({this.key, this.canvas});

  final _i3.Key? key;

  final _i3.Widget? canvas;

  @override
  String toString() {
    return 'MapRouteArgs{key: $key, canvas: $canvas}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MapRouteArgs) return false;
    return key == other.key && canvas == other.canvas;
  }

  @override
  int get hashCode => key.hashCode ^ canvas.hashCode;
}
