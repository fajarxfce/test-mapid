import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.large),
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Card(padding: padding, child: child);
}
