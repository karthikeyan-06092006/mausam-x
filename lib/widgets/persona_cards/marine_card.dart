import 'package:flutter/material.dart';
import '../../models/marine_data.dart';

class MarineCard extends StatelessWidget {
  final MarineData marine;
  final String cityName;

  const MarineCard({
    super.key,
    required this.marine,
    required this.cityName,
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
                  Icon(Icons.waves, color: Color(0xFF38BDF8), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'BEACH & MARINE CONDITIONS',
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
                  color: const Color(0xFF0284C7).withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Coastal Feed',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Coastal Safety Flag Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF0284C7).withAlpha(80)),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag, color: Color(0xFF38BDF8), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'COASTAL SAFETY ADVISORY',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        marine.seaSafetyFlag,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Wave, Swell, Sea Temp Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMarineItem('Wave Height', '${marine.waveHeight.toStringAsFixed(1)} m'),
              _buildMarineItem('Wave Period', '${marine.wavePeriod.toStringAsFixed(1)} s'),
              _buildMarineItem('Swell Height', '${marine.swellWaveHeight.toStringAsFixed(1)} m'),
              _buildMarineItem('Sea Surface Temp', '${marine.seaSurfaceTemperature.toStringAsFixed(1)} °C'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarineItem(String label, String value) {
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
