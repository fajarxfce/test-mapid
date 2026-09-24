import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppPageBody extends StatelessWidget {
  const AppPageBody({
    required this.child,
    this.maxWidth = 1040,
    this.controller,
    super.key,
  });
  final Widget child;
  final double maxWidth;
  final ScrollController? controller;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        controller: controller,
        padding: EdgeInsets.all(
          constraints.maxWidth < AppSpacing.compactBreakpoint
              ? AppSpacing.medium
              : AppSpacing.page,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        ),
      ),
    ),
  );
}
