sealed class BusException implements Exception {
  final String message;
  const BusException(this.message);

  @override
  String toString() => message;
}

/// Couldn't reach the sheet (network, timeout, non-200).
class BusFetchException extends BusException {
  final int? statusCode;
  const BusFetchException({required String message, this.statusCode})
    : super(message);
}

/// Got a response, but it isn't the sheet we expect (layout changed, or the
/// sheet stopped being public and Google returned a login page).
class BusFormatException extends BusException {
  const BusFormatException(super.message);
}
