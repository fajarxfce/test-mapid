import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:core_design_system/src/tokens/app_text_variant.dart';
import 'package:core_design_system/src/widgets/typography/app_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppSection extends StatelessWidget {
  const AppSection({
    required this.title,
    required this.child,
    this.description,
    super.key,
  });
  final String title;
  final String? description;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      AppText(title, variant: AppTextVariant.subtitle),
      if (description != null) ...[
        const SizedBox(height: AppSpacing.small),
        AppText(
          description!,
          color: FluentTheme.of(context).resources.textFillColorSecondary,
        ),
      ],
      const SizedBox(height: AppSpacing.medium),
      child,
    ],
  );
}
