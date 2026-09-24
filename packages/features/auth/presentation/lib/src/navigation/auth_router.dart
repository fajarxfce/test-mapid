import 'package:auth_presentation/src/login/bloc/login_bloc.dart';
import 'package:auth_presentation/src/navigation/auth_router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

/// Feature route configuration. The app owns the running RootStackRouter.
@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AuthRouter {
  AuthRouter(this._container);
  final GetIt _container;

  List<AutoRoute> get routes => [
    AutoRoute(
      page: LoginRoute.page.copyWith(
        builder: (data) => BlocProvider(
          create: (_) => _container<LoginBloc>(),
          child: LoginRoute.page.builder(data),
        ),
      ),
      path: '/login',
    ),
  ];
}
