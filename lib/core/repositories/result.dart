/// Result wrapper for repository operations.
/// Encapsulates success value or error message.
class RepositoryResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const RepositoryResult._({this.data, this.error, required this.isSuccess});

  factory RepositoryResult.success(T data) =>
      RepositoryResult._(data: data, isSuccess: true);

  factory RepositoryResult.failure(String error) =>
      RepositoryResult._(error: error, isSuccess: false);

  bool get isFailure => !isSuccess;
}
