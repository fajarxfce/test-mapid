import 'package:core_design_system/src/widgets/inputs/app_field.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppTimePicker extends StatelessWidget {
  const AppTimePicker({
    required this.value,
    required this.onChanged,
    this.label,
    this.errorText,
    this.hourFormat = HourFormat.HH,
    this.minuteIncrement = 1,
    this.locale,
    this.focusNode,
    super.key,
  });
  final DateTime? value;
  final ValueChanged<DateTime>? onChanged;
  final String? label;
  final String? errorText;
  final HourFormat hourFormat;
  final int minuteIncrement;
  final Locale? locale;
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) => AppField(
    label: label,
    errorText: errorText,
    child: TimePicker(
      selected: value,
      onChanged: onChanged,
      hourFormat: hourFormat,
      minuteIncrement: minuteIncrement,
      locale: locale,
      focusNode: focusNode,
    ),
  );
}
