class AqiModel {
  final int aqi;
  final String city;
  final double pm25;
  final double pm10;

  AqiModel({
    required this.aqi,
    required this.city,
    required this.pm25,
    required this.pm10,
  });

  factory AqiModel.fromJson(Map<String, dynamic> json) {
    return AqiModel(
      aqi: json['data']['aqi'],
      city: json['data']['city']['name'],
      pm25: json['data']['iaqi']['pm25']['v'].toDouble(),
      pm10: json['data']['iaqi']['pm10']['v'].toDouble(),
    );
  }
}