import 'package:auth_presentation/src/login/bloc/login_bloc.dart';
import 'package:auth_presentation/src/login/bloc/login_event.dart';
import 'package:auth_presentation/src/login/bloc/login_state.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<LoginBloc, LoginState>(
    builder: (context, state) {
      final bloc = context.read<LoginBloc>();
      final busy = state.isSubmitting;
      return ScaffoldPage(
        content: AppPageBody(
          maxWidth: 440,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppGap(AppSpacing.page),
              const AppBrandHeader(
                title: 'Fluent Starter',
                subtitle: 'Sign in to your workspace.',
              ),
              const AppGap(),
              Align(
                alignment: Alignment.centerLeft,
                child: AppBadge(
                  label: state.environment,
                  semanticsLabel: 'Environment: ${state.environment}',
                ),
              ),
              const AppGap(AppSpacing.large),
              AppCard(
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        key: const Key('login_email'),
                        label: 'Email address',
                        enabled: !busy,
                        errorText: state.emailError,
                        placeholder: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.username],
                        textInputAction: TextInputAction.next,
                        onChanged: (email) =>
                            bloc.add(LoginEmailChanged(email)),
                      ),
                      const AppGap(),
                      AppPasswordField(
                        key: const Key('login_password'),
                        label: 'Password',
                        enabled: !busy,
                        errorText: state.passwordError,
                        placeholder: 'At least 8 characters',
                        onChanged: (password) =>
                            bloc.add(LoginPasswordChanged(password)),
                        onSubmitted: (_) => bloc.add(const LoginSubmitted()),
                      ),
                      const AppGap(AppSpacing.large),
                      AppButton(
                        key: const Key('login_submit'),
                        label: 'Sign in',
                        isLoading: busy && state.activeProvider == null,
                        onPressed: busy
                            ? null
                            : () => bloc.add(const LoginSubmitted()),
                      ),
                      if (state.providers.isNotEmpty) ...[
                        const AppGap(),
                        const Center(child: AppText('or')),
                        const AppGap(),
                        for (final provider in state.providers)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.small,
                            ),
                            child: AppButton(
                              key: ValueKey('login_${provider.name}'),
                              label: provider.label,
                              variant: AppButtonVariant.secondary,
                              isLoading: state.activeProvider == provider,
                              onPressed: busy
                                  ? null
                                  : () => bloc.add(
                                      LoginProviderSubmitted(provider),
                                    ),
                            ),
                          ),
                      ],
                      if (state.error != null) ...[
                        const AppGap(),
                        AppInfoBar(
                          title: 'Unable to sign in',
                          message: state.error!,
                          status: AppStatus.error,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (state.isDemo) ...[
                const AppGap(AppSpacing.large),
                const AppInfoBar(
                  title: 'Demo workspace',
                  selectable: true,
                  message:
                      'Email: demo@example.com\nPassword: Demo123!\n'
                      'Google and GitHub buttons use simulated demo accounts.',
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
