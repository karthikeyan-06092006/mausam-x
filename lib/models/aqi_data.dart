class AqiData {
  final int aqi;
  final double pm2_5;
  final double pm10;
  final double no2;
  final double o3;
  final double so2;
  final double co;
  final double uvIndex;
  final double pollenAlder;
  final double pollenBirch;
  final double pollenGrass;
  final double pollenMugwort;
  final double pollenOlive;
  final double pollenRagweed;
  final List<HourlyAqi> hourlyAqi;

  AqiData({
    required this.aqi,
    required this.pm2_5,
    required this.pm10,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.co,
    required this.uvIndex,
    required this.pollenAlder,
    required this.pollenBirch,
    required this.pollenGrass,
    required this.pollenMugwort,
    required this.pollenOlive,
    required this.pollenRagweed,
    required this.hourlyAqi,
  });

  String get aqiCategory {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Satisfactory / Moderate';
    if (aqi <= 200) return 'Moderate / Unhealthy for Sensitive';
    if (aqi <= 300) return 'Poor';
    if (aqi <= 400) return 'Very Poor';
    return 'Severe / Hazardous';
  }

  String get healthAdvisory {
    if (aqi <= 50) return 'Air quality is ideal. Great for outdoor exercises.';
    if (aqi <= 100) return 'Air quality is acceptable. Sensitive individuals should monitor symptoms.';
    if (aqi <= 200) return 'Sensitive groups may experience respiratory irritation. Limit prolonged outdoor workouts.';
    if (aqi <= 300) return 'Unhealthy. Wear an N95 mask outdoors and avoid heavy cardiovascular workouts.';
    if (aqi <= 400) return 'Very Unhealthy. Keep windows shut, use air purifiers, stay indoors.';
    return 'Severe Emergency! Hazardous air conditions. Avoid all outdoor physical activity.';
  }

  factory AqiData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] ?? {};
    final hourly = json['hourly'] ?? {};

    final List<HourlyAqi> hourlyList = [];
    final List<dynamic> times = hourly['time'] ?? [];
    final List<dynamic> aqis = hourly['us_aqi'] ?? hourly['european_aqi'] ?? [];
    final List<dynamic> pm25s = hourly['pm2_5'] ?? [];
    final List<dynamic> pm10s = hourly['pm10'] ?? [];
    final List<dynamic> uvs = hourly['uv_index'] ?? [];

    for (int i = 0; i < times.length; i++) {
      hourlyList.add(HourlyAqi(
        time: DateTime.parse(times[i]),
        aqi: (aqis.length > i ? aqis[i] : 50)?.toInt() ?? 50,
        pm2_5: (pm25s.length > i ? pm25s[i] : 15.0)?.toDouble() ?? 15.0,
        pm10: (pm10s.length > i ? pm10s[i] : 30.0)?.toDouble() ?? 30.0,
        uvIndex: (uvs.length > i ? uvs[i] : 0.0)?.toDouble() ?? 0.0,
      ));
    }

    final calculatedAqi = (current['us_aqi'] ?? current['european_aqi'] ?? (hourlyList.isNotEmpty ? hourlyList.first.aqi : 60)).toInt();

    return AqiData(
      aqi: calculatedAqi,
      pm2_5: (current['pm2_5'] ?? (hourlyList.isNotEmpty ? hourlyList.first.pm2_5 : 18.5)).toDouble(),
      pm10: (current['pm10'] ?? (hourlyList.isNotEmpty ? hourlyList.first.pm10 : 42.0)).toDouble(),
      no2: (current['nitrogen_dioxide'] ?? 20.0).toDouble(),
      o3: (current['ozone'] ?? 45.0).toDouble(),
      so2: (current['sulphur_dioxide'] ?? 8.0).toDouble(),
      co: (current['carbon_monoxide'] ?? 350.0).toDouble(),
      uvIndex: (current['uv_index'] ?? (hourlyList.isNotEmpty ? hourlyList.first.uvIndex : 3.0)).toDouble(),
      pollenAlder: (current['alder_pollen'] ?? 0.0).toDouble(),
      pollenBirch: (current['birch_pollen'] ?? 0.0).toDouble(),
      pollenGrass: (current['grass_pollen'] ?? 2.0).toDouble(),
      pollenMugwort: (current['mugwort_pollen'] ?? 0.0).toDouble(),
      pollenOlive: (current['olive_pollen'] ?? 0.0).toDouble(),
      pollenRagweed: (current['ragweed_pollen'] ?? 1.0).toDouble(),
      hourlyAqi: hourlyList,
    );
  }
}

class HourlyAqi {
  final DateTime time;
  final int aqi;
  final double pm2_5;
  final double pm10;
  final double uvIndex;

  HourlyAqi({
    required this.time,
    required this.aqi,
    required this.pm2_5,
    required this.pm10,
    required this.uvIndex,
  });
}
