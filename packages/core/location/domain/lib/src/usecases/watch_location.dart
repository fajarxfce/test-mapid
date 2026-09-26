import 'package:core_common/core_common.dart';
import 'package:core_lifecycle_domain/core_lifecycle_domain.dart';
import 'package:core_location_domain/src/entities/location_fix.dart';
import 'package:core_location_domain/src/repositories/location_access_repository.dart';
import 'package:core_location_domain/src/repositories/location_repository.dart';
import 'package:rxdart/rxdart.dart';

/// Foreground position and bearing updates; cancellation releases device sensors.
final class WatchLocation {
  const WatchLocation(this._repository, this._access, this._lifecycle);
  final LocationRepository _repository;
  final LocationAccessRepository _access;
  final AppLifecycleRepository _lifecycle;

  Stream<Result<LocationFix>> call() => Rx.defer(() {
    // A fresh user request may prompt once. All subsequent resumes are passive.
    var mayRequestPermission = true;
    return _lifecycle.watchForeground().distinct().switchMap((foreground) {
      if (!foreground) {
        return Stream.value(
          const FailureResult<LocationFix>(
            Failure(
              FailureKind.cancelled,
              'Foreground location tracking is paused.',
            ),
          ),
        );
      }
      final allowPrompt = mayRequestPermission;
      mayRequestPermission = false;
      // Keep observing visibility after a failed acquisition so Settings can
      // restore access. Switching to the background cancels the current session.
      return _access
          .checkAccess()
          .switchMap(
            (access) => switch (access) {
              FailureResult(
                failure: Failure(kind: FailureKind.permissionDenied),
              )
                  when allowPrompt =>
                Stream.fromFuture(_access.requestPermission()),
              _ => Stream.value(access),
            },
          )
          .switchMap(
            (access) => switch (access) {
              Success() => _repository.watch(),
              FailureResult(:final failure) => Stream.value(
                FailureResult<LocationFix>(failure),
              ),
            },
          );
    });
  });
}
