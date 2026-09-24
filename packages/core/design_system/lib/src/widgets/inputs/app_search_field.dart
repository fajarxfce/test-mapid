import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:core_design_system/src/widgets/buttons/app_icon_button.dart';
import 'package:core_design_system/src/widgets/inputs/app_text_field.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// Search/debounce/clear behavior belongs to the caller.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    this.label,
    this.placeholder = 'Search',
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.clearLabel = 'Clear search',
    this.enabled = true,
    super.key,
  });
  final String? label;
  final String placeholder;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final String clearLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) => AppTextField(
    label: label,
    placeholder: placeholder,
    controller: controller,
    focusNode: focusNode,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    enabled: enabled,
    textInputAction: TextInputAction.search,
    prefix: const Padding(
      padding: EdgeInsetsDirectional.only(start: AppSpacing.small),
      child: ExcludeSemantics(child: Icon(FluentIcons.search)),
    ),
    suffix: onClear == null
        ? null
        : AppIconButton(
            icon: FluentIcons.clear,
            tooltip: clearLabel,
            onPressed: enabled ? onClear : null,
          ),
  );
}
