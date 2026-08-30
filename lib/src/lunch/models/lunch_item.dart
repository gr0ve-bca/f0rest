class LunchFoodIcon {
  final String icon;

  const LunchFoodIcon({required this.icon});

  @override
  bool operator ==(Object other) =>
      other is LunchFoodIcon && other.icon == icon;

  @override
  int get hashCode => icon.hashCode;
}

class LunchItem {
  final String name;
  final String description;
  final List<LunchFoodIcon> icons;
  final Map<String, dynamic>? nutrition;

  const LunchItem({
    required this.name,
    required this.description,
    required this.icons,
    this.nutrition,
  });

  @override
  bool operator ==(Object other) =>
      other is LunchItem &&
      other.name == name &&
      other.description == description;

  @override
  int get hashCode => Object.hash(name, description);
}

class LunchEntry {
  final String station;
  final LunchItem food;

  const LunchEntry({required this.station, required this.food});
}
