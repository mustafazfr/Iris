class WorkingHourModel {
  final int dayOfWeek; // 1..7 (ISO: 1=Mon, 7=Sun)
  final String? openingTime;   // "HH:MM:SS"
  final String? closingTime;   // "HH:MM:SS"
  final bool isClosed;

  WorkingHourModel({
    required this.dayOfWeek,
    required this.openingTime,
    required this.closingTime,
    required this.isClosed,
  });

  factory WorkingHourModel.fromMap(Map<String, dynamic> m) {
    return WorkingHourModel(
      dayOfWeek: (m['day_of_week'] as num).toInt(),
      openingTime: m['opening_time'] as String?,
      closingTime: m['closing_time'] as String?,
      isClosed: (m['is_closed'] as bool?) ?? false,
    );
  }
}
