abstract interface class AppLifecycleRepository {
  /// Current visibility followed by changes. Losing focus alone is not hiding.
  /// Cancelling the subscription releases the lifecycle observer.
  Stream<bool> watchForeground();
}
