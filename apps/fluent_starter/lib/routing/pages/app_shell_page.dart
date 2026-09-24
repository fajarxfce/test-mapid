import 'package:auto_route/auto_route.dart';
import 'package:fluent_starter/routing/widgets/app_shell_view.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:home_presentation/home_presentation.dart';
import 'package:settings_presentation/settings_presentation.dart';

@RoutePage()
class AppShellPage extends StatelessWidget {
  const AppShellPage({super.key});
  @override
  Widget build(BuildContext context) => AutoTabsRouter(
    homeIndex: 0,
    routes: const [HomeRoute(), SettingsRoute()],
    builder: (context, child) {
      final tabs = AutoTabsRouter.of(context);
      return AppShellView(
        selectedIndex: tabs.activeIndex,
        onDestinationSelected: tabs.setActiveIndex,
        child: child,
      );
    },
  );
}
