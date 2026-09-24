import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:settings_presentation/src/appearance/pages/appearance_view.dart';

@RoutePage()
class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) => const AppearanceView();
}
