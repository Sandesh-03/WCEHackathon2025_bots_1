class WeatherModel {
  final String city;
  final double temperature;
  final String description;

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.description,
  });

  /// ✅ Correctly parses JSON into a WeatherModel instance
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
  return WeatherModel(
    city: json['name'] ?? 'Unknown',
    temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0, // ✅ Handle null
    description: json['weather'] != null && json['weather'].isNotEmpty
        ? json['weather'][0]['description'] ?? 'No description'
        : 'No description',
  );
}


  /// ✅ Converts WeatherModel to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'temp': temperature,
      'description': description,
    };
  }
}
