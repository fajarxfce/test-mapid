import 'package:core_design_system/src/tokens/app_radius.dart';
import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:core_design_system/src/tokens/app_status.dart';
import 'package:core_design_system/src/tokens/app_text_variant.dart';
import 'package:core_design_system/src/widgets/typography/app_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    this.status = AppStatus.neutral,
    this.semanticsLabel,
    super.key,
  });
  final String label;
  final AppStatus status;
  final String? semanticsLabel;
  @override
  Widget build(BuildContext context) {
    final colors = FluentTheme.of(context).resources;
    final background = switch (status) {
      AppStatus.neutral => colors.systemFillColorNeutralBackground,
      AppStatus.info => colors.systemFillColorAttentionBackground,
      AppStatus.success => colors.systemFillColorSuccessBackground,
      AppStatus.warning => colors.systemFillColorCautionBackground,
      AppStatus.error => colors.systemFillColorCriticalBackground,
    };
    return Semantics(
      label: semanticsLabel ?? label,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.small,
              vertical: AppSpacing.xSmall,
            ),
            child: AppText(
              label,
              variant: AppTextVariant.caption,
              color: colors.textFillColorPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
