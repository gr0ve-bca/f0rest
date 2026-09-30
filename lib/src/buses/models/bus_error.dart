sealed class BusException implements Exception {
  final String message;
  const BusException(this.message);

  @override
  String toString() => message;
}

class BusFetchException extends BusException {
  final int? statusCode;
  const BusFetchException({required String message, this.statusCode})
    : super(message);
}

class BusFormatException extends BusException {
  const BusFormatException(super.message);
}
