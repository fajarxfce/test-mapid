import 'package:core_design_system/src/widgets/inputs/app_text_field.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppTextArea extends StatelessWidget {
  const AppTextArea({
    this.label,
    this.placeholder,
    this.helpText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.minLines = 3,
    this.maxLines = 8,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    super.key,
  });
  final String? label;
  final String? placeholder;
  final String? helpText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final int minLines;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;

  @override
  Widget build(BuildContext context) => AppTextField(
    label: label,
    placeholder: placeholder,
    helpText: helpText,
    errorText: errorText,
    controller: controller,
    focusNode: focusNode,
    onChanged: onChanged,
    minLines: minLines,
    maxLines: maxLines,
    maxLength: maxLength,
    enabled: enabled,
    readOnly: readOnly,
    keyboardType: TextInputType.multiline,
    textInputAction: TextInputAction.newline,
  );
}
