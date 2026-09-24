import 'package:core_design_system/src/tokens/app_radius.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// A decorative loading placeholder. Announce loading with AppLoadingState.
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    this.width,
    this.height = 16,
    this.borderRadius = AppRadius.control,
    super.key,
  });
  final double? width;
  final double height;
  final double borderRadius;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: FluentTheme.of(context).resources.controlAltFillColorSecondary,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    ),
  );
}
