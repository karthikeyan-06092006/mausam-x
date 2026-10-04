class MarineData {
  final double waveHeight;
  final double wavePeriod;
  final int waveDirection;
  final double windWaveHeight;
  final double swellWaveHeight;
  final double seaSurfaceTemperature;
  final bool isCoastal;

  MarineData({
    required this.waveHeight,
    required this.wavePeriod,
    required this.waveDirection,
    required this.windWaveHeight,
    required this.swellWaveHeight,
    required this.seaSurfaceTemperature,
    this.isCoastal = true,
  });

  String get seaSafetyFlag {
    if (waveHeight < 1.0) return 'Green Flag (Calm & Safe)';
    if (waveHeight < 2.0) return 'Yellow Flag (Moderate - Caution)';
    if (waveHeight < 3.0) return 'Orange Flag (Rough - High Risk)';
    return 'Red Flag (Severe / Danger - Avoid Entering Sea)';
  }

  factory MarineData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] ?? {};
    final hourly = json['hourly'] ?? {};
    
    double getVal(dynamic val) {
      if (val == null) return 0.0;
      if (val is List && val.isNotEmpty) return (val.first ?? 0.0).toDouble();
      return (val as num).toDouble();
    }

    return MarineData(
      waveHeight: getVal(current['wave_height'] ?? hourly['wave_height'] ?? 0.8),
      wavePeriod: getVal(current['wave_period'] ?? hourly['wave_period'] ?? 6.5),
      waveDirection: getVal(current['wave_direction'] ?? hourly['wave_direction'] ?? 180).toInt(),
      windWaveHeight: getVal(current['wind_wave_height'] ?? hourly['wind_wave_height'] ?? 0.4),
      swellWaveHeight: getVal(current['swell_wave_height'] ?? hourly['swell_wave_height'] ?? 0.6),
      seaSurfaceTemperature: getVal(current['sea_surface_temperature'] ?? hourly['sea_surface_temperature'] ?? 27.5),
    );
  }

  factory MarineData.empty() {
    return MarineData(
      waveHeight: 0.0,
      wavePeriod: 0.0,
      waveDirection: 0,
      windWaveHeight: 0.0,
      swellWaveHeight: 0.0,
      seaSurfaceTemperature: 0.0,
      isCoastal: false,
    );
  }
}
