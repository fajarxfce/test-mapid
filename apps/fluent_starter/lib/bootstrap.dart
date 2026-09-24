import 'package:fluent_starter/app.dart';
import 'package:fluent_starter/config/app_config.dart';
import 'package:fluent_starter/di/injection.dart';
import 'package:fluent_starter/routing/app_router.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_presentation/settings_presentation.dart';

Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = await configureDependencies(config);
  runApp(
    MultiBlocProvider(
      providers: [BlocProvider.value(value: container<AppearanceBloc>())],
      child: FluentStarterApp(routerConfig: container<AppRouter>().config()),
    ),
  );
}
