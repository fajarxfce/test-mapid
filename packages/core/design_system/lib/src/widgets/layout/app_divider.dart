import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({
    this.direction = Axis.horizontal,
    this.spacing = AppSpacing.medium,
    this.length,
    super.key,
  });
  final Axis direction;
  final double spacing;
  final double? length;
  @override
  Widget build(BuildContext context) => Padding(
    padding: direction == Axis.horizontal
        ? EdgeInsets.symmetric(vertical: spacing)
        : EdgeInsets.symmetric(horizontal: spacing),
    child: Divider(direction: direction, size: length),
  );
}
