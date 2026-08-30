sealed class LunchException implements Exception {
  final String message;
  const LunchException(this.message);

  @override
  String toString() => message;
}

class LunchFetchException extends LunchException {
  final int? statusCode;
  final DateTime date;

  const LunchFetchException({
    required String message,
    required this.date,
    this.statusCode,
  }) : super(message);
}
