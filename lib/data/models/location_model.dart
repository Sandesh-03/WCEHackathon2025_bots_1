class LocationModel {
  final String id;
  final String name;
  final String city;
  final double lat;
  final double lon;

  LocationModel({
    required this.id,
    required this.name,
    required this.city,
    required this.lat,
    required this.lon,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      lat: json['lat'],
      lon: json['lon'],
    );
  }
}
