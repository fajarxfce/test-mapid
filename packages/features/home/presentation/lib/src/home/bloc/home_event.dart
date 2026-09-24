import 'package:identity_domain/identity_domain.dart';

sealed class HomeEvent {
  const HomeEvent();
}

final class HomeSessionCheckRequested extends HomeEvent {
  const HomeSessionCheckRequested();
}

final class HomeLogoutRequested extends HomeEvent {
  const HomeLogoutRequested();
}

final class HomeSessionExpiryRequested extends HomeEvent {
  const HomeSessionExpiryRequested();
}

final class HomeSessionChanged extends HomeEvent {
  const HomeSessionChanged(this.session);
  final Session session;
}
