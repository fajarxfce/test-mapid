import 'package:core_design_system/src/models/app_select_option.dart';
import 'package:core_design_system/src/tokens/app_control_size.dart';
import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:core_design_system/src/widgets/inputs/app_field.dart';
import 'package:core_design_system/src/widgets/typography/app_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppRadioGroup<T> extends StatelessWidget {
  const AppRadioGroup({
    required this.options,
    required this.onChanged,
    this.value,
    this.label,
    this.errorText,
    this.direction = Axis.vertical,
    super.key,
  });
  final List<AppSelectOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? label;
  final String? errorText;
  final Axis direction;
  @override
  Widget build(BuildContext context) {
    final items = [
      for (final option in options)
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: AppControlSize.standard.minHeight,
          ),
          child: RadioButton<T>(
            value: option.value,
            enabled: option.enabled && onChanged != null,
            content: AppText(option.label),
          ),
        ),
    ];
    return AppField(
      label: label,
      errorText: errorText,
      child: RadioGroup<T>(
        groupValue: value,
        onChanged: (selected) => onChanged?.call(selected),
        child: direction == Axis.horizontal
            ? Wrap(
                spacing: AppSpacing.medium,
                runSpacing: AppSpacing.small,
                children: items,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: items,
              ),
      ),
    );
  }
}
