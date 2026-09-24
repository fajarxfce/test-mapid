import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:map_presentation/map_presentation.dart';

@lazySingleton
class AppRouter extends RootStackRouter {
  AppRouter(this._mapRouter);
  final MapRouter _mapRouter;
  @override
  List<AutoRoute> get routes => [
    ..._mapRouter.routes,
    RedirectRoute(path: '*', redirectTo: '/'),
  ];
  @disposeMethod
  void close() => dispose();
}
