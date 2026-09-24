import 'package:auth_presentation/src/login/inputs/email_input.dart';
import 'package:auth_presentation/src/login/inputs/password_input.dart';
import 'package:auth_presentation/src/login/models/login_provider.dart';
import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

@freezed
abstract class LoginState with _$LoginState {
  const LoginState._();
  const factory LoginState({
    @Default('') String environment,
    @Default(false) bool isDemo,
    @Default([]) List<LoginProvider> providers,
    LoginProvider? activeProvider,
    @Default(EmailInput.pure()) EmailInput email,
    @Default(PasswordInput.pure()) PasswordInput password,
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus status,
    String? error,
  }) = _LoginState;

  bool get isSubmitting => status.isInProgress;
  String? get emailError =>
      email.displayError == null ? null : 'Enter a valid email address.';
  String? get passwordError =>
      password.displayError == null ? null : 'Use at least 8 characters.';
}
