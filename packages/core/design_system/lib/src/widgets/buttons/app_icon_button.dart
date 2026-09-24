import 'package:core_design_system/src/tokens/app_control_size.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = AppControlSize.standard,
    this.focusNode,
    super.key,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final AppControlSize size;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    excludeFromSemantics: true,
    child: Semantics(
      label: tooltip,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: size.minHeight,
          minWidth: size.minHeight,
        ),
        child: IconButton(
          icon: ExcludeSemantics(child: Icon(icon)),
          onPressed: onPressed,
          focusNode: focusNode,
        ),
      ),
    ),
  );
}
