
import '../entities/aqi.dart';

abstract class AQIRepository {
  Future<AQI> getAQI(double lat, double lon);
}
