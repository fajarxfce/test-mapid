import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:identity_domain/identity_domain.dart';

class FakeIdentityRepository
    implements IdentityRepository, DemoSessionRepository {
  FakeIdentityRepository([this.session = const SessionUnauthenticated()]);

  final _controller = StreamController<Session>.broadcast();
  final actions = <String>[];
  Future<Result<User?>>? pendingRestore;
  Result<void> logoutResult = const Success(null);
  Result<void> expireResult = const Success(null);

  @override
  Set<IdentityProvider> get providers => const {};
  @override
  Future<Result<User>> loginWithProvider(IdentityProvider provider) =>
      throw UnimplementedError();

  @override
  Session session;

  @override
  Stream<Session> get sessionChanges => Stream.multi((controller) {
    final sub = _controller.stream.listen(
      controller.addSync,
      onDone: controller.closeSync,
    );
    controller.addSync(session);
    controller.onCancel = sub.cancel;
  }, isBroadcast: true);

  bool get hasListener => _controller.hasListener;

  void update(Session value) {
    session = value;
    _controller.add(value);
  }

  @override
  Future<Result<User?>> restoreSession() {
    actions.add('check');
    return pendingRestore ?? Future.value(Success(session.user));
  }

  @override
  Future<Result<void>> logout() async {
    actions.add('logout');
    update(const SessionUnauthenticated());
    return logoutResult;
  }

  @override
  Future<Result<void>> expireSession() async {
    actions.add('expire');
    return expireResult;
  }

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  Future<void> close() => _controller.close();
}
