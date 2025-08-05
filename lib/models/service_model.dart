class ServiceModel {
  final String serviceId;
  final String serviceName;
  final String? description;
  final Duration estimatedTime; // interval verisi string formatında tutulur (örnek: "01:30:00")
  final double basePrice;
  final String? imageUrl;

  ServiceModel({
    required this.serviceId,
    required this.serviceName,
    this.description,
    required this.estimatedTime,
    required this.basePrice,
    this.imageUrl,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: json['service_id'] as String? ?? '', // null ise boş string ata
      serviceName: json['service_name'] as String? ?? 'İsimsiz Servis', // null ise varsayılan isim ata
      description: json['description'] as String?,
      estimatedTime: _parseDuration(json['estimated_time'] as String? ?? '00:00:00'),
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'service_name': serviceName,
      'description': description,
      'estimated_time': _formatDuration(estimatedTime),
      'base_price': basePrice,
    };
  }
  static Duration _parseDuration(String s) {
    final parts = s.split(':');
    if (parts.length != 3) return Duration.zero;
    try {
      return Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
        seconds: int.parse(parts[2]),
      );
    } catch (e) {
      return Duration.zero;
    }
  }
  static String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}

