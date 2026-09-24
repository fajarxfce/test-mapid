import 'package:identity_domain/src/entities/user.dart';

/// Business session state; never contains tokens or presentation feedback.
sealed class Session {
  const Session();

  User? get user => null;
  bool get isAuthenticated => this is SessionAuthenticated;
}

final class SessionUninitialized extends Session {
  const SessionUninitialized();
}

final class SessionUnauthenticated extends Session {
  const SessionUnauthenticated();
}

final class SessionAuthenticated extends Session {
  const SessionAuthenticated(this.user);

  @override
  final User user;
}
