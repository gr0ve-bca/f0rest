import 'package:f0rest/src/lunch/models/lunch_error.dart';
import 'package:f0rest/src/lunch/models/lunch_item.dart';
import 'package:f0rest/src/lunch/parsing/nutrislice_parser.dart';
import 'package:f0rest/src/lunch/sources/lunch_source.dart';
import 'package:http/http.dart' as http;

class NutrisliceSource implements LunchSource {
  NutrisliceSource({
    http.Client? client,
    String Function(String url)? urlTransform,
  }) : _client = client ?? http.Client(),
       _urlTransform = urlTransform;

  final http.Client _client;
  final String Function(String url)? _urlTransform;

  static const _school = 'bergen-academy';

  @override
  Future<List<LunchEntry>> fetchMenu(DateTime date) async {
    final baseUrl =
        'https://bergen.api.nutrislice.com/menu/api/weeks/school/'
        '$_school/menu-type/lunch/'
        '${date.year}/${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}?format=json';

    final url = _urlTransform?.call(baseUrl) ?? baseUrl;

    final response = await _client.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw LunchFetchException(
        message: 'Failed to fetch menu for $date: ${response.statusCode}',
        date: date,
        statusCode: response.statusCode,
      );
    }

    return NutrisliceParser().parseDay(response.body, date);
  }
}
