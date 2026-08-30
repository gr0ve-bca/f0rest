import 'package:f0rest/src/lunch/models/lunch_item.dart';

abstract interface class LunchSource {
  Future<List<LunchEntry>> fetchMenu(DateTime date);
}
