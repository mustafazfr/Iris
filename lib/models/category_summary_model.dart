// lib/models/category_summary_model.dart

class CategorySummaryModel {
  final String categoryId;
  final String name;
  final String? iconUrl;
  final int serviceCount;

  CategorySummaryModel({
    required this.categoryId,
    required this.name,
    this.iconUrl,
    required this.serviceCount,
  });

  factory CategorySummaryModel.fromJson(Map<String, dynamic> json) {
    return CategorySummaryModel(
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String?,
      serviceCount: json['service_count'] as int,
    );
  }
}