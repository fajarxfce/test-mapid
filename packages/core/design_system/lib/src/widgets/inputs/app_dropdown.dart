import 'package:core_design_system/src/models/app_select_option.dart';
import 'package:core_design_system/src/widgets/inputs/app_field.dart';
import 'package:core_design_system/src/widgets/typography/app_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    required this.options,
    required this.onChanged,
    this.value,
    this.label,
    this.placeholder,
    this.helpText,
    this.errorText,
    this.enabled = true,
    this.focusNode,
    super.key,
  });
  final List<AppSelectOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? label;
  final String? placeholder;
  final String? helpText;
  final String? errorText;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) => AppField(
    label: label,
    helpText: helpText,
    errorText: errorText,
    child: ComboBox<T>(
      value: value,
      onChanged: enabled ? onChanged : null,
      focusNode: focusNode,
      isExpanded: true,
      placeholder: placeholder == null ? null : AppText(placeholder!),
      items: [
        for (final option in options)
          ComboBoxItem<T>(
            value: option.value,
            enabled: option.enabled,
            child: AppText(option.label),
          ),
      ],
    ),
  );
}
