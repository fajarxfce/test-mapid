import 'package:auth_presentation/src/login/inputs/input_error.dart';
import 'package:formz/formz.dart';

class EmailInput extends FormzInput<String, InputError> {
  const EmailInput.pure() : super.pure('');
  const EmailInput.dirty([super.value = '']) : super.dirty();
  @override
  InputError? validator(String value) {
    if (value.isEmpty) return InputError.empty;
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)
        ? null
        : InputError.invalid;
  }
}
