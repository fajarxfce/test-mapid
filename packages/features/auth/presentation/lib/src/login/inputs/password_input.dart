import 'package:auth_presentation/src/login/inputs/input_error.dart';
import 'package:formz/formz.dart';

class PasswordInput extends FormzInput<String, InputError> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty([super.value = '']) : super.dirty();
  @override
  InputError? validator(String value) => value.isEmpty
      ? InputError.empty
      : value.length < 8
      ? InputError.invalid
      : null;
}
