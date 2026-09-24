import 'package:fluent_ui/fluent_ui.dart';

/// Value is a fraction in [0, 1]; null means indeterminate.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({this.value, this.label = 'Loading', super.key})
    : assert(value == null || (value >= 0 && value <= 1));
  final double? value;
  final String label;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    value: value == null ? null : '${(value! * 100).round()}%',
    child: ExcludeSemantics(
      child: ProgressBar(value: value == null ? null : value! * 100),
    ),
  );
}
