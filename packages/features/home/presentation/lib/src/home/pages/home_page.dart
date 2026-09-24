import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// Hosts the home stack inside the app's home tab.
@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const AutoRouter();
}
