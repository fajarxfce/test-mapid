import 'package:core_design_system/src/widgets/typography/app_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onPressed,
    this.focusNode,
    super.key,
  });
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) => ListTile(
    title: AppText(title),
    subtitle: subtitle == null ? null : AppText(subtitle!),
    leading: leading,
    trailing: trailing,
    onPressed: onPressed,
    focusNode: focusNode,
  );
}
