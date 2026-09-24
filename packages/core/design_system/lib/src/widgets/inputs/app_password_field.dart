import 'package:core_design_system/src/widgets/buttons/app_icon_button.dart';
import 'package:core_design_system/src/widgets/inputs/app_text_field.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppPasswordField extends StatelessWidget {
  const AppPasswordField({
    this.label,
    this.placeholder,
    this.errorText,
    this.helpText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.obscureText = true,
    this.onObscureTextChanged,
    this.showPasswordLabel = 'Show password',
    this.hidePasswordLabel = 'Hide password',
    this.autofillHints = const [AutofillHints.password],
    this.textInputAction = TextInputAction.done,
    super.key,
  });
  final String? label;
  final String? placeholder;
  final String? errorText;
  final String? helpText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool obscureText;
  final ValueChanged<bool>? onObscureTextChanged;
  final String showPasswordLabel;
  final String hidePasswordLabel;
  final Iterable<String> autofillHints;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) => AppTextField(
    label: label,
    placeholder: placeholder,
    errorText: errorText,
    helpText: helpText,
    controller: controller,
    focusNode: focusNode,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    enabled: enabled,
    obscureText: obscureText,
    autocorrect: false,
    enableSuggestions: false,
    autofillHints: autofillHints,
    textInputAction: textInputAction,
    suffix: onObscureTextChanged == null
        ? null
        : AppIconButton(
            icon: obscureText ? FluentIcons.view : FluentIcons.hide,
            tooltip: obscureText ? showPasswordLabel : hidePasswordLabel,
            onPressed: enabled
                ? () => onObscureTextChanged!(!obscureText)
                : null,
          ),
  );
}
