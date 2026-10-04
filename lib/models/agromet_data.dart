class AgrometData {
  final double soilMoisture0to7cm; // m³/m³
  final double soilMoisture7to28cm;
  final double soilTemperature0cm;
  final double evapotranspiration;
  final bool frostWarning;
  final String irrigationAdvisory;
  final String sprayingAdvisory;

  AgrometData({
    required this.soilMoisture0to7cm,
    required this.soilMoisture7to28cm,
    required this.soilTemperature0cm,
    required this.evapotranspiration,
    required this.frostWarning,
    required this.irrigationAdvisory,
    required this.sprayingAdvisory,
  });

  factory AgrometData.fromHourlyWeatherAndSoil({
    required double soilMoisture0_7,
    required double soilMoisture7_28,
    required double soilTemp,
    required double et0,
    required double minTempNext24h,
    required double rainProbNext24h,
    required double maxWindNext24h,
  }) {
    bool frost = minTempNext24h <= 2.0;

    String irrig;
    if (rainProbNext24h > 50) {
      irrig = 'Hold irrigation: Rain expected in the next 24-48 hours.';
    } else if (soilMoisture0_7 < 0.18) {
      irrig = 'Soil is dry (Moisture < 18%). Immediate irrigation recommended.';
    } else if (soilMoisture0_7 > 0.38) {
      irrig = 'Adequate soil saturation. No irrigation required today.';
    } else {
      irrig = 'Optimal soil moisture levels maintained.';
    }

    String spray;
    if (maxWindNext24h > 20) {
      spray = 'Avoid pesticide/fertilizer spraying: High wind gusts will cause drift.';
    } else if (rainProbNext24h > 40) {
      spray = 'Do not spray chemicals: Rain might wash off application.';
    } else {
      spray = 'Favorable weather window for pesticide and nutrient spraying.';
    }

    return AgrometData(
      soilMoisture0to7cm: soilMoisture0_7,
      soilMoisture7to28cm: soilMoisture7_28,
      soilTemperature0cm: soilTemp,
      evapotranspiration: et0,
      frostWarning: frost,
      irrigationAdvisory: irrig,
      sprayingAdvisory: spray,
    );
  }

  factory AgrometData.fromJson(Map<String, dynamic> json, double minTemp24h, double rainProb24h, double wind24h) {
    final hourly = json['hourly'] ?? {};
    
    double getVal(String key, double fallback) {
      final list = hourly[key];
      if (list is List && list.isNotEmpty) {
        return (list.first ?? fallback).toDouble();
      }
      return fallback;
    }

    final sm07 = getVal('soil_moisture_0_to_7cm', 0.24);
    final sm728 = getVal('soil_moisture_7_to_28cm', 0.28);
    final st0 = getVal('soil_temperature_0cm', 24.0);
    final et0 = getVal('et0_fao_evapotranspiration', 3.5);

    return AgrometData.fromHourlyWeatherAndSoil(
      soilMoisture0_7: sm07,
      soilMoisture7_28: sm728,
      soilTemp: st0,
      et0: et0,
      minTempNext24h: minTemp24h,
      rainProbNext24h: rainProb24h,
      maxWindNext24h: wind24h,
    );
  }
}
