import 'package:auto_route/auto_route.dart';
import 'package:core_common/core_common.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:home_presentation/home_presentation.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart';

import '../support/fake_identity_repository.dart';

void main() {
  testWidgets('mounts the generated feature subtree without app or auth', (
    tester,
  ) async {
    final session = FakeIdentityRepository(
      const SessionAuthenticated(
        User(
          id: 'host',
          email: 'host@example.com',
          displayName: 'Feature host',
        ),
      ),
    );
    final container = GetIt.asNewInstance();
    container.registerSingleton<GetIt>(container);
    container.registerSingleton(WatchSession(session));
    container.registerSingleton(GetCurrentSession(session));
    container.registerSingleton(RestoreSession(session));
    container.registerSingleton(Logout(session));
    container.registerSingleton(ExpireDemoSession(session));
    container.registerSingleton(
      const AppEnvironment(label: 'test', isDemo: false),
    );
    await HomePresentationPackageModule().init(GetItHelper(container));
    final router = RootStackRouter.build(
      routes: [
        RedirectRoute(path: '/', redirectTo: '/workspace'),
        AutoRoute(
          page: EmptyShellRoute('HostShell'),
          path: '/workspace',
          children: container<HomeRouter>().routes,
        ),
      ],
    );
    addTearDown(session.close);
    addTearDown(container.reset);
    addTearDown(router.dispose);

    await tester.pumpWidget(FluentApp.router(routerConfig: router.config()));
    await tester.pumpAndSettle();
    expect(router.currentUrl, '/workspace');
    expect(router.topRoute.name, OverviewRoute.name);
    final welcome = find.text('Welcome, Feature host');
    expect(welcome, findsOneWidget);
    final bloc = tester.element(welcome).read<HomeBloc>();
    expect(session.hasListener, isTrue);
    await tester.tap(find.text('Check session'));
    await tester.pump();
    expect(session.actions, ['check']);

    await tester.pumpWidget(const SizedBox.shrink());
    // Flush SDK cancellation completion before asserting asynchronous disposal.
    await tester.runAsync(() async {});
    await tester.pumpAndSettle();
    expect(bloc.isClosed, isTrue);
    expect(session.hasListener, isFalse);
  });
}
