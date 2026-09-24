import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:core_design_system/src/tokens/app_text_variant.dart';
import 'package:core_design_system/src/widgets/typography/app_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    this.message,
    this.icon = FluentIcons.open_folder_horizontal,
    this.action,
    super.key,
  });
  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.large),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Icon(
            icon,
            size: 40,
            color: FluentTheme.of(context).resources.textFillColorSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        AppText(
          title,
          variant: AppTextVariant.subtitle,
          textAlign: TextAlign.center,
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.small),
          AppText(message!, textAlign: TextAlign.center),
        ],
        if (action != null) ...[
          const SizedBox(height: AppSpacing.medium),
          action!,
        ],
      ],
    ),
  );
}
