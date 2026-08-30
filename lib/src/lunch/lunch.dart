import 'package:f0rest/src/lunch/models/lunch_item.dart';
import 'package:f0rest/src/lunch/sources/lunch_source.dart';

class Lunch {
  final LunchSource _source;
  const Lunch(this._source);

  Future<List<LunchEntry>> fetchToday() => fetchForDate(DateTime.now());

  Future<List<LunchEntry>> fetchForDate(DateTime date) =>
      _source.fetchMenu(date);

  List<LunchEntry> search(List<LunchEntry> entries, String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return entries;
    return entries.where((entry) {
      final food = entry.food;
      return food.name.toLowerCase().contains(q) ||
          food.description.toLowerCase().contains(q);
    }).toList();
  }
}
