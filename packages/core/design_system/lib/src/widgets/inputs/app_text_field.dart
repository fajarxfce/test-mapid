import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:core_design_system/src/widgets/inputs/app_field.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

/// Editing controllers/focus nodes are optional and owned by the caller.
/// No controller is created in build, and validation is supplied as text.
class AppTextField extends StatelessWidget {
  const AppTextField({
    this.label,
    this.placeholder,
    this.helpText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.prefix,
    this.suffix,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    super.key,
  });
  final String? label;
  final String? placeholder;
  final String? helpText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final Widget? suffix;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) => AppField(
    label: label,
    helpText: helpText,
    errorText: errorText,
    child: TextBox(
      controller: controller,
      focusNode: focusNode,
      placeholder: placeholder,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      autofocus: autofocus,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      prefix: prefix,
      suffix: suffix,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      padding: const EdgeInsets.all(AppSpacing.small + AppSpacing.xSmall),
      highlightColor: errorText != null
          ? FluentTheme.of(context).resources.systemFillColorCritical
          : null,
      unfocusedColor: errorText != null
          ? FluentTheme.of(context).resources.systemFillColorCritical
          : null,
    ),
  );
}
