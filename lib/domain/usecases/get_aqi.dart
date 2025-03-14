

import '../entities/aqi.dart';
import '../repositories/aqi_repository.dart';

class GetAQI {
  final AQIRepository repository;

  GetAQI(this.repository);

  Future<AQI> call(double lat, double lon) async {
    return await repository.getAQI(lat, lon);
  }
}