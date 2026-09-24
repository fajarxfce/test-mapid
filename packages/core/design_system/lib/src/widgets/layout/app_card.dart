import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.large),
    this.backgroundColor,
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) =>
      Card(padding: padding, backgroundColor: backgroundColor, child: child);
}
