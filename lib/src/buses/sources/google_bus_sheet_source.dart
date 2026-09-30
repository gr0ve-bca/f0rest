import 'package:csv/csv.dart';
import 'package:f0rest/src/buses/models/bus_error.dart';
import 'package:f0rest/src/buses/sources/bus_source.dart';
import 'package:http/http.dart' as http;

class GoogleSheetBusSource implements BusSource {
  GoogleSheetBusSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static final url = Uri.https(
    'docs.google.com',
    '/spreadsheets/d/1S5v7kTbSiqV8GottWVi5tzpqLdTrEgWEY4ND4zvyV3o/export',
    {'format': 'csv', 'gid': '0'},
  );

  @override
  Future<List<List<String>>> fetchRows() async {
    final http.Response res;
    try {
      res = await _client.get(url).timeout(const Duration(seconds: 10));
    } on Exception catch (e) {
      throw BusFetchException(message: 'Failed to fetch bus sheet: $e');
    }
    if (res.statusCode != 200) {
      throw BusFetchException(
        message: 'Failed to fetch bus sheet: ${res.statusCode}',
        statusCode: res.statusCode,
      );
    }
    return [
      for (final row in csv.decode(res.body.replaceAll('\r\n', '\n')))
        [for (final cell in row) cell?.toString() ?? ''],
    ];
  }
}
