import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/weather_data.dart';

class ImdSevenDayForecastCard extends StatelessWidget {
  final List<DailyWeather> dailyList;

  const ImdSevenDayForecastCard({super.key, required this.dailyList});

  IconData _getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny_outlined;
    if (code == 1 || code == 2) return Icons.wb_cloudy_outlined;
    if (code == 3) return Icons.cloud_outlined;
    if (code >= 51 && code <= 67) return Icons.water_drop_outlined;
    if (code >= 80) return Icons.grain;
    return Icons.wb_cloudy_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF135398).withAlpha(190),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(40)),
      ),
      child: Column(
        children: dailyList.map((day) {
          final isToday = day.date.day == DateTime.now().day;
          final dateStr = DateFormat('dd/MM').format(day.date);
          final dayName = isToday ? 'Today' : DateFormat('EEEE').format(day.date);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                // Date and Day Column
                SizedBox(
                  width: 70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                      Text(
                        dayName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Weather Icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Icon(
                    _getWeatherIcon(day.weatherCode),
                    color: Colors.white,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 4),

                // Min Temp
                SizedBox(
                  width: 44,
                  child: Text(
                    '${day.minTemp.toStringAsFixed(1)}°',
                    style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),

                const SizedBox(width: 4),

                // Gradient Range Bar matching photo (Yellow -> Orange -> Red)
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFDE047), // Yellow
                          Color(0xFFF97316), // Orange
                          Color(0xFFEF4444), // Red
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Max Temp
                SizedBox(
                  width: 44,
                  child: Text(
                    '${day.maxTemp.toStringAsFixed(1)}°',
                    style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),

                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Colors.white70, size: 16),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
