import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// Hosts settings pages without adding individual pages to the app tab list.
@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => const AutoRouter();
}
