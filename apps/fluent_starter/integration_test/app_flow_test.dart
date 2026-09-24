import 'package:fluent_starter/app.dart';
import 'package:fluent_starter/config/app_config.dart';
import 'package:fluent_starter/di/injection.dart';
import 'package:fluent_starter/routing/app_router.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings_presentation/settings_presentation.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Widget app(GetIt container) => MultiBlocProvider(
    providers: [BlocProvider.value(value: container<AppearanceBloc>())],
    child: FluentStarterApp(routerConfig: container<AppRouter>().config()),
  );

  for (final method in ['password', 'google', 'github']) {
    testWidgets(
      'native $method login survives container recreation and logs out',
      (tester) async {
        final config = AppConfig.fromEnvironment();
        final email = method == 'password'
            ? 'demo@example.com'
            : '$method@example.com';
        final name = switch (method) {
          'google' => 'Google Demo User',
          'github' => 'GitHub Demo User',
          _ => 'Alex Morgan',
        };
        final first = await configureDependencies(config);
        await first<Logout>()();
        await tester.pumpWidget(app(first));
        await tester.pumpAndSettle();
        if (method == 'password') {
          await tester.enterText(find.byKey(const Key('login_email')), email);
          await tester.enterText(
            find.byKey(const Key('login_password')),
            'Demo123!',
          );
          await tester.tap(find.byKey(const Key('login_submit')));
        } else {
          final button = find.byKey(Key('login_$method'));
          await tester.ensureVisible(button);
          await tester.tap(button);
        }
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.text('Welcome, $name'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        await first.reset();

        final restored = await configureDependencies(config);
        expect(restored<GetCurrentSession>()().user?.email, email);
        await tester.pumpWidget(app(restored));
        await tester.pumpAndSettle();
        expect(find.text('Welcome, $name'), findsOneWidget);
        await tester.tap(find.byKey(const Key('logout')));
        await tester.pumpAndSettle();
        expect(find.text('Sign in'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        await restored.reset();
      },
    );
  }
}
