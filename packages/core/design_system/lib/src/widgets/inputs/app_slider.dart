import 'package:core_design_system/src/widgets/inputs/app_field.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppSlider extends StatelessWidget {
  const AppSlider({
    required this.value,
    required this.onChanged,
    this.label,
    this.valueLabel,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChangeEnd,
    this.focusNode,
    super.key,
  });
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final String? label;
  final String? valueLabel;
  final double min;
  final double max;
  final int? divisions;
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) => AppField(
    label: label,
    child: Semantics(
      label: label,
      child: Slider(
        value: value,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
        min: min,
        max: max,
        divisions: divisions,
        label: valueLabel,
        focusNode: focusNode,
      ),
    ),
  );
}
