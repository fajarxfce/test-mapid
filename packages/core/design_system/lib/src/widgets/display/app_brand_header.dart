import 'package:core_design_system/src/widgets/layout/app_page_header.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppBrandHeader extends StatelessWidget {
  const AppBrandHeader({
    required this.title,
    this.subtitle,
    this.icon = FluentIcons.app_icon_default,
    super.key,
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  @override
  Widget build(BuildContext context) => AppPageHeader(
    title: title,
    subtitle: subtitle,
    leading: ExcludeSemantics(
      child: Icon(icon, size: 36, color: FluentTheme.of(context).accentColor),
    ),
  );
}
