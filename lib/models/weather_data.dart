class WeatherData {
  final double currentTemp;
  final double apparentTemp;
  final int relativeHumidity;
  final double precipitationProbability;
  final double precipitation;
  final double windSpeed;
  final int windDirection;
  final double windGusts;
  final double uvIndex;
  final double visibilityMeters;
  final int weatherCode;
  final double surfacePressure;
  final double cloudCover;
  final String sunrise;
  final String sunset;
  final List<HourlyWeather> hourlyForecast;
  final List<DailyWeather> dailyForecast;

  WeatherData({
    required this.currentTemp,
    required this.apparentTemp,
    required this.relativeHumidity,
    required this.precipitationProbability,
    required this.precipitation,
    required this.windSpeed,
    required this.windDirection,
    required this.windGusts,
    required this.uvIndex,
    required this.visibilityMeters,
    required this.weatherCode,
    required this.surfacePressure,
    required this.cloudCover,
    required this.sunrise,
    required this.sunset,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  String get weatherCondition => getWeatherDescription(weatherCode);

  static String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear Sky';
      case 1:
        return 'Mainly Clear';
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Overcast';
      case 45:
        return 'Fog';
      case 48:
        return 'Depositing Rime Fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snowfall';
      case 80:
      case 81:
      case 82:
        return 'Rain Showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with Hail';
      default:
        return 'Fair';
    }
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] ?? {};
    final hourly = json['hourly'] ?? {};
    final daily = json['daily'] ?? {};

    final List<HourlyWeather> hourlyList = [];
    final List<dynamic> times = hourly['time'] ?? [];
    final List<dynamic> temps = hourly['temperature_2m'] ?? [];
    final List<dynamic> rainProbs = hourly['precipitation_probability'] ?? [];
    final List<dynamic> rains = hourly['precipitation'] ?? [];
    final List<dynamic> humidities = hourly['relative_humidity_2m'] ?? [];
    final List<dynamic> visibilities = hourly['visibility'] ?? [];
    final List<dynamic> windSpeeds = hourly['wind_speed_10m'] ?? [];
    final List<dynamic> uvs = hourly['uv_index'] ?? [];
    final List<dynamic> weatherCodes = hourly['weather_code'] ?? [];

    for (int i = 0; i < times.length; i++) {
      hourlyList.add(HourlyWeather(
        time: DateTime.parse(times[i]),
        temperature: (temps.length > i ? temps[i] : 0.0)?.toDouble() ?? 0.0,
        precipitationProbability: (rainProbs.length > i ? rainProbs[i] : 0)?.toDouble() ?? 0.0,
        precipitation: (rains.length > i ? rains[i] : 0.0)?.toDouble() ?? 0.0,
        humidity: (humidities.length > i ? humidities[i] : 0)?.toInt() ?? 0,
        visibilityMeters: (visibilities.length > i ? visibilities[i] : 10000.0)?.toDouble() ?? 10000.0,
        windSpeed: (windSpeeds.length > i ? windSpeeds[i] : 0.0)?.toDouble() ?? 0.0,
        uvIndex: (uvs.length > i ? uvs[i] : 0.0)?.toDouble() ?? 0.0,
        weatherCode: (weatherCodes.length > i ? weatherCodes[i] : 0)?.toInt() ?? 0,
      ));
    }

    final List<DailyWeather> dailyList = [];
    final List<dynamic> dTimes = daily['time'] ?? [];
    final List<dynamic> maxTemps = daily['temperature_2m_max'] ?? [];
    final List<dynamic> minTemps = daily['temperature_2m_min'] ?? [];
    final List<dynamic> maxRainProbs = daily['precipitation_probability_max'] ?? [];
    final List<dynamic> dWeatherCodes = daily['weather_code'] ?? [];

    for (int i = 0; i < dTimes.length; i++) {
      dailyList.add(DailyWeather(
        date: DateTime.parse(dTimes[i]),
        maxTemp: (maxTemps.length > i ? maxTemps[i] : 0.0)?.toDouble() ?? 0.0,
        minTemp: (minTemps.length > i ? minTemps[i] : 0.0)?.toDouble() ?? 0.0,
        precipitationProbability: (maxRainProbs.length > i ? maxRainProbs[i] : 0)?.toDouble() ?? 0.0,
        weatherCode: (dWeatherCodes.length > i ? dWeatherCodes[i] : 0)?.toInt() ?? 0,
      ));
    }

    final List<dynamic> sunrises = daily['sunrise'] ?? [];
    final List<dynamic> sunsets = daily['sunset'] ?? [];

    return WeatherData(
      currentTemp: (current['temperature_2m'] ?? 0.0).toDouble(),
      apparentTemp: (current['apparent_temperature'] ?? current['temperature_2m'] ?? 0.0).toDouble(),
      relativeHumidity: (current['relative_humidity_2m'] ?? 0).toInt(),
      precipitationProbability: hourlyList.isNotEmpty ? hourlyList.first.precipitationProbability : 0.0,
      precipitation: (current['precipitation'] ?? 0.0).toDouble(),
      windSpeed: (current['wind_speed_10m'] ?? 0.0).toDouble(),
      windDirection: (current['wind_direction_10m'] ?? 0).toInt(),
      windGusts: (current['wind_gusts_10m'] ?? 0.0).toDouble(),
      uvIndex: (current['uv_index'] ?? (hourlyList.isNotEmpty ? hourlyList.first.uvIndex : 0.0)).toDouble(),
      visibilityMeters: (hourlyList.isNotEmpty ? hourlyList.first.visibilityMeters : 10000.0).toDouble(),
      weatherCode: (current['weather_code'] ?? 0).toInt(),
      surfacePressure: (current['surface_pressure'] ?? 1013.25).toDouble(),
      cloudCover: (current['cloud_cover'] ?? 0.0).toDouble(),
      sunrise: sunrises.isNotEmpty ? sunrises.first.toString() : '06:00',
      sunset: sunsets.isNotEmpty ? sunsets.first.toString() : '18:30',
      hourlyForecast: hourlyList,
      dailyForecast: dailyList,
    );
  }
}

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final double precipitationProbability;
  final double precipitation;
  final int humidity;
  final double visibilityMeters;
  final double windSpeed;
  final double uvIndex;
  final int weatherCode;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.precipitationProbability,
    required this.precipitation,
    required this.humidity,
    required this.visibilityMeters,
    required this.windSpeed,
    required this.uvIndex,
    required this.weatherCode,
  });

  String get weatherCondition => WeatherData.getWeatherDescription(weatherCode);
}

class DailyWeather {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final double precipitationProbability;
  final int weatherCode;

  DailyWeather({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitationProbability,
    required this.weatherCode,
  });

  String get weatherCondition => WeatherData.getWeatherDescription(weatherCode);
}
