import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:core_design_system/src/widgets/typography/app_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// Dialog content only. Routing/presentation code owns showing and dismissing it.
class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.title,
    required this.child,
    this.actions = const [],
    this.maxWidth = 480,
    super.key,
  });
  final String title;
  final Widget child;
  final List<Widget> actions;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => ContentDialog(
    title: AppText(title),
    content: SingleChildScrollView(child: child),
    constraints: BoxConstraints(maxWidth: maxWidth),
    actions: actions.isEmpty
        ? null
        : [
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: actions,
            ),
          ],
  );
}
