import 'package:core_design_system/src/widgets/inputs/app_field.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppDatePicker extends StatelessWidget {
  const AppDatePicker({
    required this.value,
    required this.onChanged,
    this.label,
    this.errorText,
    this.startDate,
    this.endDate,
    this.locale,
    this.focusNode,
    super.key,
  });
  final DateTime? value;
  final ValueChanged<DateTime>? onChanged;
  final String? label;
  final String? errorText;
  final DateTime? startDate;
  final DateTime? endDate;
  final Locale? locale;
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) => AppField(
    label: label,
    errorText: errorText,
    child: DatePicker(
      selected: value,
      onChanged: onChanged,
      startDate: startDate,
      endDate: endDate,
      locale: locale,
      focusNode: focusNode,
    ),
  );
}
