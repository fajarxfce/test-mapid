import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:core_design_system/src/widgets/typography/app_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// Fluent owns transient disclosure state; the callback reports expansion only.
class AppExpander extends StatelessWidget {
  const AppExpander({
    required this.title,
    required this.child,
    this.leading,
    this.initiallyExpanded = false,
    this.onChanged,
    this.enabled = true,
    super.key,
  });
  final String title;
  final Widget child;
  final Widget? leading;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  @override
  Widget build(BuildContext context) => Expander(
    header: AppText(title),
    content: child,
    leading: leading,
    initiallyExpanded: initiallyExpanded,
    onStateChanged: onChanged,
    enabled: enabled,
    contentPadding: const EdgeInsets.all(AppSpacing.medium),
  );
}
