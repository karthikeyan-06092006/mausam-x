import 'package:flutter/material.dart';
import '../../models/weather_data.dart';

class CommuterCard extends StatelessWidget {
  final WeatherData weather;

  const CommuterCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final visM = weather.visibilityMeters;
    final isDenseFog = visM < 300;
    final isMist = visM < 1500 && visM >= 300;

    String fogText;
    Color fogColor;
    if (isDenseFog) {
      fogText = 'Dense Fog Alert (Visibility < 300m). Use low-beam fog lamps.';
      fogColor = const Color(0xFFEF4444);
    } else if (isMist) {
      fogText = 'Moderate Mist/Haze on highways. Maintain safe braking distance.';
      fogColor = const Color(0xFFF59E0B);
    } else {
      fogText = 'Clear road visibility. Favorable driving conditions.';
      fogColor = const Color(0xFF10B981);
    }

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
                  Icon(Icons.directions_car, color: Color(0xFF38BDF8), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'HIGHWAY & COMMUTER WATCH',
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
                  color: fogColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isDenseFog ? 'Fog Risk' : 'Traffic Weather',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fogColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Visibility Gauge & Advice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Road Visibility', style: TextStyle(fontSize: 11, color: Colors.white54)),
                    Text(
                      visM < 1000 ? '${visM.round()} m' : '${(visM / 1000).toStringAsFixed(1)} km',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: fogColor),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    fogText,
                    style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Commute stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCommuteItem('Rain Risk', '${weather.precipitationProbability.round()}%'),
              _buildCommuteItem('Wind Gusts', '${weather.windGusts.round()} km/h'),
              _buildCommuteItem('Cloud Cover', '${weather.cloudCover.round()}%'),
              _buildCommuteItem('Road Wetness', weather.precipitation > 0.5 ? 'Wet' : 'Dry'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommuteItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
        ],
      ),
    );
  }
}
