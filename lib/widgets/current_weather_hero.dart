import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../models/aqi_data.dart';

class CurrentWeatherHero extends StatelessWidget {
  final WeatherData weather;
  final AqiData? aqi;

  const CurrentWeatherHero({
    super.key,
    required this.weather,
    this.aqi,
  });

  IconData _getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code == 1 || code == 2) return Icons.wb_cloudy;
    if (code == 3) return Icons.cloud;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 67) return Icons.water_drop;
    if (code >= 80 && code <= 82) return Icons.grain;
    if (code >= 95) return Icons.thunderstorm;
    return Icons.wb_sunny;
  }

  Color _getAqiColor(int aqiValue) {
    if (aqiValue <= 50) return const Color(0xFF10B981); // Good Green
    if (aqiValue <= 100) return const Color(0xFFFBBF24); // Satisfactory Yellow
    if (aqiValue <= 200) return const Color(0xFFF97316); // Moderate Orange
    if (aqiValue <= 300) return const Color(0xFFEF4444); // Poor Red
    if (aqiValue <= 400) return const Color(0xFF8B5CF6); // Very Poor Purple
    return const Color(0xFF7F1D1D); // Severe Maroon
  }

  @override
  Widget build(BuildContext context) {
    final daily = weather.dailyForecast.isNotEmpty ? weather.dailyForecast.first : null;
    final maxT = daily?.maxTemp ?? weather.currentTemp + 3;
    final minT = daily?.minTemp ?? weather.currentTemp - 4;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Weather Condition & AQI Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _getWeatherIcon(weather.weatherCode),
                    color: const Color(0xFF38BDF8),
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    weather.weatherCondition,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (aqi != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getAqiColor(aqi!.aqi).withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getAqiColor(aqi!.aqi).withAlpha(120)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getAqiColor(aqi!.aqi),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'AQI ${aqi!.aqi} • ${aqi!.aqiCategory.split('/').first.trim()}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getAqiColor(aqi!.aqi),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Middle: Huge Temp & Min/Max
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.currentTemp.round()}',
                    style: const TextStyle(
                      fontSize: 68,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 0.9,
                    ),
                  ),
                  const Text(
                    '°C',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Feels like ${weather.apparentTemp.round()}°C',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'H: ${maxT.round()}°  •  L: ${minT.round()}°',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 16),

          // Bottom Key Metrics Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(
                icon: Icons.water_drop_outlined,
                label: 'Rain Chance',
                value: '${weather.precipitationProbability.round()}%',
                color: const Color(0xFF38BDF8),
              ),
              _buildMetricItem(
                icon: Icons.air,
                label: 'Wind',
                value: '${weather.windSpeed.round()} km/h',
                color: const Color(0xFF2DD4BF),
              ),
              _buildMetricItem(
                icon: Icons.wb_sunny_outlined,
                label: 'UV Index',
                value: weather.uvIndex.toStringAsFixed(1),
                color: const Color(0xFFF59E0B),
              ),
              _buildMetricItem(
                icon: Icons.visibility_outlined,
                label: 'Visibility',
                value: '${(weather.visibilityMeters / 1000).toStringAsFixed(1)} km',
                color: const Color(0xFFA78BFA),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}
