import 'package:f0rest/src/lunch/models/lunch_item.dart';
import 'dart:convert';

class NutrisliceParser {
  List<LunchEntry> parseDay(String rawJson, DateTime date) {
    final data = json.decode(rawJson) as Map<String, dynamic>;
    final days = data['days'] as List;

    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final today = days.firstWhere(
      (d) => d['date'] == dateStr && (d['menu_items'] as List).isNotEmpty,
      orElse: () => null,
    );

    if (today == null) return [];

    final items = today['menu_items'] as List;
    String currentStation = '';
    final List<LunchEntry> results = [];

    for (final item in items) {
      if (item['is_section_title'] == true &&
          item['food'] == null &&
          item['text'] != null) {
        currentStation = item['text'];
        continue;
      }
      if (item['food'] != null) {
        results.add(
          LunchEntry(station: currentStation, food: _parseItem(item['food'])),
        );
      }
    }
    return results;
  }

  LunchItem _parseItem(Map<String, dynamic> json) {
    return LunchItem(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      nutrition: json['rounded_nutrition_info'],
      icons: (json['icons']?['food_icons'] as List? ?? [])
          .map((i) => LunchFoodIcon(icon: i['sprite']?['help_text'] ?? ''))
          .toList(),
    );
  }
}
