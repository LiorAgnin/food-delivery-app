import 'failures/api_error.dart';

/// A call that finished. Transport and the contract envelope never throw
/// past the data layer; callers branch on this.
sealed class ApiResult<T> {
  const ApiResult();
}

final class ApiOk<T> extends ApiResult<T> {
  const ApiOk(this.value);

  final T value;
}

final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.error);

  final ApiError error;
}
