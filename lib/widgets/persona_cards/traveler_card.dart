import 'package:flutter/material.dart';
import '../../models/weather_data.dart';

class TravelerCard extends StatelessWidget {
  final WeatherData weather;
  final String currentCity;

  const TravelerCard({
    super.key,
    required this.weather,
    required this.currentCity,
  });

  List<String> _getPackingAdvice() {
    final List<String> items = [];
    if (weather.precipitationProbability > 40 || weather.weatherCode >= 51) {
      items.add('Compact Umbrella / Windbreaker (Rain expected)');
    }
    if (weather.currentTemp < 18) {
      items.add('Warm Jacket / Fleece (Chilly temperatures)');
    } else if (weather.currentTemp > 32) {
      items.add('Sun Hat, Sunglasses & Sunscreen (High heat/UV)');
    }
    if (weather.uvIndex > 6) {
      items.add('UV Protection Sunglasses & Lip Balm');
    }
    if (items.isEmpty) {
      items.add('Comfortable light cotton clothing & walking shoes');
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final packingList = _getPackingAdvice();

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
                  Icon(Icons.flight_takeoff, color: Color(0xFF38BDF8), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'TRAVEL & PACKING COMPANION',
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
                  color: const Color(0xFF38BDF8).withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Flight & Transit Safe',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Packing Assistant Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.luggage_outlined, color: Color(0xFFF59E0B), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'SMART PACKING LIST FOR CURRENT LOCATION',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...packingList.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_box_outlined, color: Color(0xFF10B981), size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(item, style: const TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Quick Multi-City Transit Strip
          const Text(
            'Saved Destination Forecasts:',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white54),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCityChip('Delhi (DEL)', '31°C • Hazy'),
              _buildCityChip('Mumbai (BOM)', '29°C • Pleasant'),
              _buildCityChip('Bengaluru (BLR)', '24°C • Breezy'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCityChip(String city, String condition) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(city, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(condition, style: const TextStyle(fontSize: 10, color: Colors.white60)),
        ],
      ),
    );
  }
}
