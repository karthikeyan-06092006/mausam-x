import 'package:flutter/material.dart';
import '../../models/weather_data.dart';

class FamilyCard extends StatelessWidget {
  final WeatherData weather;

  const FamilyCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final rainProb = weather.precipitationProbability;
    final isRainyCommute = rainProb > 35;

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
                  Icon(Icons.family_restroom, color: Color(0xFFF472B6), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'PARENTS & SCHOOL COMMUTE',
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
                  color: const Color(0xFFF472B6).withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Family Safety',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF472B6)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Morning & Afternoon School Windows
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Morning Drop-off (7:30 AM)', style: TextStyle(fontSize: 11, color: Colors.white54)),
                      const SizedBox(height: 4),
                      Text(
                        isRainyCommute ? 'Rain Gear Needed ☔' : 'Clear & Dry ☀️',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Afternoon Pickup (2:30 PM)', style: TextStyle(fontSize: 11, color: Colors.white54)),
                      const SizedBox(height: 4),
                      Text(
                        weather.apparentTemp > 34 ? 'High Heat Caution 🌡️' : 'Pleasant Commute ✨',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 10),

          // Kids Outdoor Play Advisory
          Row(
            children: [
              const Icon(Icons.sports_soccer, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  weather.uvIndex > 7
                      ? 'High midday UV (${weather.uvIndex.toStringAsFixed(1)}). Schedule outdoor play after 4:30 PM.'
                      : 'Good outdoor play weather. Ensure kids stay hydrated.',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
