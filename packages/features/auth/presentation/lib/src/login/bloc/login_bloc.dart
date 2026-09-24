import 'package:auth_presentation/src/login/bloc/login_event.dart';
import 'package:auth_presentation/src/login/bloc/login_state.dart';
import 'package:auth_presentation/src/login/inputs/email_input.dart';
import 'package:auth_presentation/src/login/inputs/password_input.dart';
import 'package:auth_presentation/src/login/models/login_provider.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core_common/core_common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart';

@injectable
final class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(
    this._login,
    this._loginWithProvider,
    GetIdentityProviders providers,
    AppEnvironment environment,
  ) : super(
        LoginState(
          environment: environment.label,
          isDemo: environment.isDemo,
          providers: providers()
              .map(
                (provider) => switch (provider) {
                  IdentityProvider.google => LoginProvider.google,
                  IdentityProvider.github => LoginProvider.github,
                },
              )
              .toList(growable: false),
        ),
      ) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted, transformer: droppable());
    on<LoginProviderSubmitted>(_onProviderSubmitted, transformer: droppable());
  }
  final Login _login;
  final LoginWithProvider _loginWithProvider;

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    if (state.status.isInProgress) return;
    emit(
      state.copyWith(
        email: EmailInput.dirty(event.email.trim()),
        error: null,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    if (state.status.isInProgress) return;
    emit(
      state.copyWith(
        password: PasswordInput.dirty(event.password),
        error: null,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.status.isInProgress || state.status.isSuccess) return;
    final email = EmailInput.dirty(state.email.value);
    final password = PasswordInput.dirty(state.password.value);
    emit(state.copyWith(email: email, password: password, error: null));
    if (!Formz.validate([email, password])) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    final result = await _login(email: email.value, password: password.value);
    _finish(result, emit);
  }

  Future<void> _onProviderSubmitted(
    LoginProviderSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.status.isInProgress || state.status.isSuccess) return;
    if (!state.providers.contains(event.provider)) return;
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.inProgress,
        activeProvider: event.provider,
        error: null,
      ),
    );
    final provider = switch (event.provider) {
      LoginProvider.google => IdentityProvider.google,
      LoginProvider.github => IdentityProvider.github,
    };
    _finish(await _loginWithProvider(provider), emit);
  }

  void _finish(Result<User> result, Emitter<LoginState> emit) {
    if (emit.isDone) return;
    switch (result) {
      case Success<User>():
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.success,
            activeProvider: null,
          ),
        );
      case FailureResult<User>(:final failure):
        emit(
          state.copyWith(
            status: failure.kind == FailureKind.cancelled
                ? FormzSubmissionStatus.initial
                : FormzSubmissionStatus.failure,
            activeProvider: null,
            error: failure.kind == FailureKind.cancelled
                ? null
                : failure.message,
          ),
        );
    }
  }
}
