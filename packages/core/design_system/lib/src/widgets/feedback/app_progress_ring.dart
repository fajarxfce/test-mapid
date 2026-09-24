import 'package:fluent_ui/fluent_ui.dart';

/// Value is a fraction in [0, 1]; null means indeterminate.
class AppProgressRing extends StatelessWidget {
  const AppProgressRing({
    this.value,
    this.size = 32,
    this.strokeWidth = 3,
    this.label = 'Loading',
    super.key,
  }) : assert(value == null || (value >= 0 && value <= 1));
  final double? value;
  final double size;
  final double strokeWidth;
  final String label;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    value: value == null ? null : '${(value! * 100).round()}%',
    child: ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: ProgressRing(
          value: value == null ? null : value! * 100,
          strokeWidth: strokeWidth,
        ),
      ),
    ),
  );
}
