import 'package:flutter/material.dart';
import '../../models/weather_data.dart';
import '../../models/aqi_data.dart';

class FitnessCard extends StatelessWidget {
  final WeatherData weather;
  final AqiData? aqi;

  const FitnessCard({
    super.key,
    required this.weather,
    this.aqi,
  });

  @override
  Widget build(BuildContext context) {
    // Determine best running window (morning cooler temp & lower UV)
    final sunriseStr = weather.sunrise.contains('T') ? weather.sunrise.split('T').last : weather.sunrise;
    final sunsetStr = weather.sunset.contains('T') ? weather.sunset.split('T').last : weather.sunset;

    final isHeatStress = weather.apparentTemp > 36.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.directions_run, color: Color(0xFF10B981), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'OUTDOOR FITNESS & RUNNING',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Workout Optimization',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Best running hours highlight
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF065F46)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.timer_outlined, color: Color(0xFF34D399), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OPTIMAL RUNNING WINDOW TODAY',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFA7F3D0)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '6:00 AM – 7:45 AM (Coolest & Lowest UV)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Sunrise, Sunset, Wind, Heat Index
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric('Sunrise', sunriseStr, Icons.wb_twilight, const Color(0xFFF59E0B)),
              _buildMetric('Sunset', sunsetStr, Icons.nights_stay_outlined, const Color(0xFF818CF8)),
              _buildMetric('Wind Speed', '${weather.windSpeed.round()} km/h', Icons.air, const Color(0xFF38BDF8)),
              _buildMetric('Heat Stress', isHeatStress ? 'High Risk' : 'Low/Safe', Icons.thermostat, isHeatStress ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
        ],
      ),
    );
  }
}
