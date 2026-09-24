import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_presentation/src/home/bloc/home_bloc.dart';
import 'package:home_presentation/src/home/bloc/home_event.dart';
import 'package:home_presentation/src/home/bloc/home_state.dart';
import 'package:home_presentation/src/home/widgets/home_overview.dart';

@RoutePage()
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeBloc, HomeState>(
    builder: (context, state) => HomeOverview(
      displayName: state.displayName,
      email: state.email,
      environment: state.environment,
      busy: state.busy,
      message: state.message,
      onCheckSession: () =>
          context.read<HomeBloc>().add(const HomeSessionCheckRequested()),
      onLogout: () => context.read<HomeBloc>().add(const HomeLogoutRequested()),
      onExpireDemoSession: state.isDemo
          ? () =>
                context.read<HomeBloc>().add(const HomeSessionExpiryRequested())
          : null,
    ),
  );
}
