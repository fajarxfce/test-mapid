import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppGap extends StatelessWidget {
  const AppGap([this.size = AppSpacing.medium, Key? key])
    : direction = Axis.vertical,
      super(key: key);
  const AppGap.horizontal([this.size = AppSpacing.medium, Key? key])
    : direction = Axis.horizontal,
      super(key: key);
  final double size;
  final Axis direction;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: direction == Axis.horizontal ? size : null,
    height: direction == Axis.vertical ? size : null,
  );
}
