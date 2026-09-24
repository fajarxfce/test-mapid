import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:core_design_system/src/tokens/app_text_variant.dart';
import 'package:core_design_system/src/widgets/typography/app_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    super.key,
  });
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (leading != null) ...[
        leading!,
        const SizedBox(height: AppSpacing.medium),
      ],
      AppText(title, variant: AppTextVariant.title),
      if (subtitle != null) ...[
        const SizedBox(height: AppSpacing.small),
        AppText(
          subtitle!,
          color: FluentTheme.of(context).resources.textFillColorSecondary,
        ),
      ],
      if (actions.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: actions,
        ),
      ],
    ],
  );
}
