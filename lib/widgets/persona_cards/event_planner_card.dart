import 'package:flutter/material.dart';
import '../../models/weather_data.dart';

class EventPlannerCard extends StatelessWidget {
  final WeatherData weather;

  const EventPlannerCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    // Calculate Outdoor Comfort Score (Humidex approximation)
    int comfortScore = 100;
    if (weather.apparentTemp > 32) comfortScore -= ((weather.apparentTemp - 32) * 5).round();
    if (weather.relativeHumidity > 70) comfortScore -= ((weather.relativeHumidity - 70) * 0.8).round();
    if (weather.precipitationProbability > 20) comfortScore -= (weather.precipitationProbability * 0.6).round();
    comfortScore = comfortScore.clamp(10, 100);

    Color scoreColor = comfortScore > 75
        ? const Color(0xFF10B981)
        : (comfortScore > 50 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));

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
                  Icon(Icons.event_available, color: Color(0xFFA855F7), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'EVENT & WEDDING WEATHER WATCH',
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
                  color: const Color(0xFFA855F7).withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Event Comfort',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFA855F7)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Outdoor Comfort Index Banner
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
                    const Text('Outdoor Comfort', style: TextStyle(fontSize: 11, color: Colors.white54)),
                    Text(
                      '$comfortScore/100',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: scoreColor),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    comfortScore > 75
                        ? 'Excellent conditions for outdoor ceremonies, tents, and evening gatherings.'
                        : 'Humid or warm atmosphere. Ensure shaded seating and cooling fans.',
                    style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 7-Day Rain Prob Forecast
          const Text(
            'Upcoming Days Rain Probability:',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white54),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: weather.dailyForecast.length,
              separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final day = weather.dailyForecast[idx];
                final rainP = day.precipitationProbability.round();
                return Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][day.date.weekday % 7],
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                      Text(
                        '$rainP% 🌧️',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: rainP > 30 ? const Color(0xFF38BDF8) : Colors.white38,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
