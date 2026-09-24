import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:settings_presentation/settings_presentation.dart';

class FluentStarterApp extends StatelessWidget {
  const FluentStarterApp({required this.routerConfig, super.key});
  final RouterConfig<Object> routerConfig;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AppearanceBloc, AppearanceState>(
        builder: (context, state) => FluentApp.router(
          title: 'Fluent Starter',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: state.mode,
          locale: const Locale('en'),
          supportedLocales: const [Locale('en')],
          localizationsDelegates: const [
            FluentLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: routerConfig,
        ),
      );
}
