import 'package:flutter/material.dart';
import '../../models/aqi_data.dart';

class HealthCard extends StatelessWidget {
  final AqiData aqi;

  const HealthCard({super.key, required this.aqi});

  Color _getAqiColor(int value) {
    if (value <= 50) return const Color(0xFF10B981);
    if (value <= 100) return const Color(0xFFFBBF24);
    if (value <= 200) return const Color(0xFFF97316);
    if (value <= 300) return const Color(0xFFEF4444);
    return const Color(0xFF8B5CF6);
  }

  @override
  Widget build(BuildContext context) {
    final color = _getAqiColor(aqi.aqi);

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
              Row(
                children: [
                  const Icon(Icons.favorite, color: Color(0xFFEF4444), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'HEALTH & AIR QUALITY DASHBOARD',
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
                  color: color.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withAlpha(120)),
                ),
                child: Text(
                  aqi.aqiCategory,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main AQI & Health Advisory
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
                    const Text('National AQI', style: TextStyle(fontSize: 11, color: Colors.white54)),
                    Text(
                      '${aqi.aqi}',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    aqi.healthAdvisory,
                    style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Pollutant Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPollutantItem('PM 2.5', '${aqi.pm2_5.toStringAsFixed(1)} µg/m³'),
              _buildPollutantItem('PM 10', '${aqi.pm10.toStringAsFixed(1)} µg/m³'),
              _buildPollutantItem('NO₂', '${aqi.no2.toStringAsFixed(1)} µg/m³'),
              _buildPollutantItem('Ozone', '${aqi.o3.toStringAsFixed(1)} µg/m³'),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 12),

          // Pollen & Allergy Levels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pollen & Allergy Index:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              Text(
                aqi.pollenGrass > 10 ? 'High Grass Pollen' : 'Low Grass & Tree Pollen',
                style: TextStyle(
                  fontSize: 12,
                  color: aqi.pollenGrass > 10 ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPollutantItem(String name, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(name, style: const TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
