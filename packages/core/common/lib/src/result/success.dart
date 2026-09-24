part of 'result.dart';

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}
