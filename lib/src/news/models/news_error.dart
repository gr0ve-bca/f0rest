sealed class NewsException implements Exception {
  final String message;

  const NewsException(this.message);

  @override
  String toString() => message;
}

class NewsFetchException extends NewsException {
  final int? statusCode;
  final int page;

  const NewsFetchException({
    required String message,
    required this.page,
    this.statusCode,
  }) : super(message);
}
