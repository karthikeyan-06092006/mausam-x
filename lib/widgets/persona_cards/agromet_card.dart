import 'package:flutter/material.dart';
import '../../models/agromet_data.dart';
import '../../models/weather_data.dart';

class AgrometCard extends StatelessWidget {
  final AgrometData agromet;
  final WeatherData weather;

  const AgrometCard({
    super.key,
    required this.agromet,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
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
                  Icon(Icons.eco, color: Color(0xFF22C55E), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'AGRICULTURE & AGROMET ADVISORY',
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
                  color: const Color(0xFF22C55E).withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Kisan / Farming',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF22C55E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Irrigation & Spraying Advisories
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.water_drop, color: Color(0xFF38BDF8), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        agromet.irrigationAdvisory,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.pest_control, color: Color(0xFFF59E0B), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        agromet.sprayingAdvisory,
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Soil Moisture & Temp Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAgriItem('Topsoil Moisture (0-7cm)', '${(agromet.soilMoisture0to7cm * 100).toStringAsFixed(1)}%'),
              _buildAgriItem('Root Moisture (7-28cm)', '${(agromet.soilMoisture7to28cm * 100).toStringAsFixed(1)}%'),
              _buildAgriItem('Soil Temp', '${agromet.soilTemperature0cm.toStringAsFixed(1)} °C'),
              _buildAgriItem('Frost Risk', agromet.frostWarning ? 'High (Warning)' : 'None (Safe)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgriItem(String label, String value) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: Colors.white54),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
