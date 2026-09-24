import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:core_design_system/src/tokens/app_text_variant.dart';
import 'package:core_design_system/src/widgets/typography/app_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// Renders validation already computed by the feature's input model/Bloc.
class AppField extends StatelessWidget {
  const AppField({
    required this.child,
    this.label,
    this.helpText,
    this.errorText,
    super.key,
  });
  final Widget child;
  final String? label;
  final String? helpText;
  final String? errorText;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (label != null)
        InfoLabel(
          label: label!,
          child: Semantics(label: label, child: child),
        )
      else
        child,
      if (errorText != null || helpText != null) ...[
        const SizedBox(height: AppSpacing.xSmall),
        Semantics(
          liveRegion: errorText != null,
          child: AppText(
            errorText ?? helpText!,
            variant: AppTextVariant.caption,
            color: errorText != null
                ? FluentTheme.of(context).resources.systemFillColorCritical
                : FluentTheme.of(context).resources.textFillColorSecondary,
          ),
        ),
      ],
    ],
  );
}
