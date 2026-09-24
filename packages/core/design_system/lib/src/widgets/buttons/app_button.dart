import 'package:core_design_system/src/tokens/app_button_variant.dart';
import 'package:core_design_system/src/tokens/app_control_size.dart';
import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:core_design_system/src/widgets/feedback/app_progress_ring.dart';
import 'package:core_design_system/src/widgets/typography/app_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// Loading preserves the label and blocks activation. The caller owns the task.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppControlSize.standard,
    this.icon,
    this.isLoading = false,
    this.loadingLabel = 'Loading',
    this.focusNode,
    this.autofocus = false,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppControlSize size;
  final Widget? icon;
  final bool isLoading;
  final String loadingLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final activate = isLoading ? null : onPressed;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          const ExcludeSemantics(
            child: AppProgressRing(size: 16, strokeWidth: 2),
          )
        else if (icon != null)
          ExcludeSemantics(child: icon!),
        if (isLoading || icon != null) const SizedBox(width: AppSpacing.small),
        Flexible(child: AppText(label, textAlign: TextAlign.center)),
      ],
    );
    final style = ButtonStyle(
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: switch (size) {
            AppControlSize.compact => AppSpacing.small + AppSpacing.xSmall,
            AppControlSize.standard => AppSpacing.medium,
            AppControlSize.large => AppSpacing.large,
          },
          vertical: switch (size) {
            AppControlSize.compact => AppSpacing.xSmall,
            AppControlSize.standard => AppSpacing.small,
            AppControlSize.large => AppSpacing.small + AppSpacing.xSmall,
          },
        ),
      ),
    );
    return Semantics(
      liveRegion: isLoading,
      value: isLoading ? loadingLabel : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: size.minHeight),
        child: switch (variant) {
          AppButtonVariant.primary => FilledButton(
            onPressed: activate,
            focusNode: focusNode,
            autofocus: autofocus,
            style: style,
            child: content,
          ),
          AppButtonVariant.secondary => Button(
            onPressed: activate,
            focusNode: focusNode,
            autofocus: autofocus,
            style: style,
            child: content,
          ),
          AppButtonVariant.outlined => OutlinedButton(
            onPressed: activate,
            focusNode: focusNode,
            autofocus: autofocus,
            style: style,
            child: content,
          ),
          AppButtonVariant.link => HyperlinkButton(
            onPressed: activate,
            focusNode: focusNode,
            autofocus: autofocus,
            style: style,
            child: content,
          ),
        },
      ),
    );
  }
}
