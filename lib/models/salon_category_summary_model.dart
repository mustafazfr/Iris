// Bu model, bir salondaki her bir kategorinin özet bilgisini tutar.
// (v_saloon_category_summary VIEW'ından gelir)
class SalonCategorySummaryModel {
  final String categoryId;
  final String name;
  final String? iconUrl;
  final int serviceCount;

  SalonCategorySummaryModel({
    required this.categoryId,
    required this.name,
    this.iconUrl,
    required this.serviceCount,
  });

  factory SalonCategorySummaryModel.fromJson(Map<String, dynamic> json) {
    return SalonCategorySummaryModel(
      categoryId: json['category_id'],
      name: json['name'],
      iconUrl: json['icon_url'],
      serviceCount: json['service_count'] ?? 0,
    );
  }

  // Equatable veya hashCode/operator== eklemek iyi bir pratiktir
  // Böylece iki nesnenin aynı olup olmadığını kolayca kontrol edebiliriz.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SalonCategorySummaryModel &&
              runtimeType == other.runtimeType &&
              categoryId == other.categoryId;

  @override
  int get hashCode => categoryId.hashCode;
}