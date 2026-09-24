import 'package:core_design_system/src/tokens/app_control_size.dart';
import 'package:core_design_system/src/widgets/typography/app_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
    this.focusNode,
    super.key,
  });
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(minHeight: AppControlSize.standard.minHeight),
    child: ToggleSwitch(
      checked: value,
      onChanged: onChanged,
      focusNode: focusNode,
      content: Flexible(child: AppText(label)),
    ),
  );
}
