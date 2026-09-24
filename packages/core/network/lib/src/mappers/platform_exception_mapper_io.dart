import 'dart:io';

import 'package:core_common/core_common.dart';

Failure? mapPlatformException(Object error) => switch (error) {
  TlsException() => const Failure(
    FailureKind.security,
    'A secure connection could not be established.',
  ),
  SocketException() || HttpException() || OSError() => const Failure(
    FailureKind.network,
    'Unable to connect. Check your connection.',
  ),
  _ => null,
};
