import 'package:denemeye_devam/models/saloon_model.dart';

class FavouriteModel {
  final String id;
  final String userId;
  final String? saloonId;
  final String? personalId;
  final DateTime createdAt;
  final SaloonModel? saloon;

  FavouriteModel({
    required this.id,
    required this.userId,
    this.saloonId,
    this.personalId,
    required this.createdAt,
    this.saloon,
  });

  factory FavouriteModel.fromJson(Map<String, dynamic> json) {
    return FavouriteModel(
      id: json['id'],
      userId: json['user_id'],
      saloonId: json['saloon_id'],
      personalId: json['personal_id'],
      createdAt: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      saloon: json['saloons'] != null
          ? SaloonModel.fromJson(json['saloons'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'saloon_id': saloonId,
      'personal_id': personalId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
