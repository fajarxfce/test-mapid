import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:home_presentation/src/home/bloc/home_bloc.dart';
import 'package:home_presentation/src/navigation/home_router.gr.dart';
import 'package:injectable/injectable.dart';

/// Routes mounted under the app shell, with feature-owned Bloc lifetimes.
@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class HomeRouter {
  HomeRouter(this._container);
  final GetIt _container;

  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeRoute.page,
      path: '',
      children: [
        AutoRoute(
          page: OverviewRoute.page.copyWith(
            builder: (data) => BlocProvider(
              create: (_) => _container<HomeBloc>(),
              child: OverviewRoute.page.builder(data),
            ),
          ),
          path: '',
        ),
      ],
    ),
  ];
}
