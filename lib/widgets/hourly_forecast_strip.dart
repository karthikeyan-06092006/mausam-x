import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_data.dart';

class HourlyForecastStrip extends StatelessWidget {
  final List<HourlyWeather> hourlyList;

  const HourlyForecastStrip({super.key, required this.hourlyList});

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

  @override
  Widget build(BuildContext context) {
    final displayHours = hourlyList.sublist(0, min(24, hourlyList.length));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule, color: Color(0xFF38BDF8), size: 18),
              SizedBox(width: 8),
              Text(
                '24-HOUR HOURLY FORECAST',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: displayHours.length,
              separatorBuilder: (ctx, idx) => const SizedBox(width: 10),
              itemBuilder: (context, idx) {
                final h = displayHours[idx];
                final timeLabel = idx == 0 ? 'Now' : DateFormat('ha').format(h.time).toLowerCase();
                final rainProb = h.precipitationProbability.round();

                return Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: idx == 0 ? const Color(0xFF38BDF8) : const Color(0xFF334155),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: idx == 0 ? FontWeight.bold : FontWeight.w500,
                          color: idx == 0 ? const Color(0xFF38BDF8) : Colors.white70,
                        ),
                      ),
                      Icon(
                        _getWeatherIcon(h.weatherCode),
                        size: 20,
                        color: const Color(0xFF38BDF8),
                      ),
                      Text(
                        '${h.temperature.round()}°',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      if (rainProb > 15)
                        Text(
                          '$rainProb%',
                          style: const TextStyle(fontSize: 9, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
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
