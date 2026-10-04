import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/weather_data.dart';
import '../../screens/imd_map_screen.dart';

class ImdDistrictWarningCard extends StatelessWidget {
  final String districtName;
  final WeatherData weather;

  const ImdDistrictWarningCard({
    super.key,
    required this.districtName,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final issueDateStr = DateFormat('yyyy-MM-dd').format(now);
    final issueTimeStr = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')} Hours';
    final validHour = (now.hour + 4) % 24;
    final validTimeStr = '${validHour.toString().padLeft(2, '0')}00 Hours';

    final isThunderstorm = weather.weatherCode >= 95 ||
        weather.weatherCondition.toLowerCase().contains('thunder') ||
        weather.weatherCondition.toLowerCase().contains('storm');

    final isRaining = !isThunderstorm &&
        ((weather.weatherCode >= 51 && weather.weatherCode <= 82) ||
            weather.precipitation > 0.0 ||
            weather.precipitationProbability >= 40 ||
            weather.weatherCondition.toLowerCase().contains('rain') ||
            weather.weatherCondition.toLowerCase().contains('drizzle') ||
            weather.weatherCondition.toLowerCase().contains('shower'));

    Color statusBgColor;
    String statusTitle;
    String weatherText;
    Color textColor;
    Color subTextColor;
    Color containerFill;

    if (isThunderstorm) {
      // RED: Thunderstorm / Severe Convective Weather
      statusBgColor = const Color(0xFFDC2626);
      statusTitle = 'WARNING (TAKE ACTION)';
      weatherText = '⚠️ - Thunderstorm with Lightning & Gusty Winds';
      textColor = Colors.white;
      subTextColor = Colors.white70;
      containerFill = Colors.black.withAlpha(35);
    } else if (isRaining) {
      // YELLOW: Raining / Showers / Precipitation
      statusBgColor = const Color(0xFFEAB308); // Official IMD Warning Yellow
      statusTitle = 'WATCH (BE UPDATED)';
      weatherText = '⚠️ - Moderate Rain / Precipitation Expected';
      textColor = const Color(0xFF0F172A); // Dark slate for maximum contrast on yellow
      subTextColor = const Color(0xFF334155);
      containerFill = Colors.black.withAlpha(20);
    } else {
      // GREEN: Fair Weather / No Warning
      statusBgColor = const Color(0xFF16A34A);
      statusTitle = 'NO WARNING (NO ACTION)';
      weatherText = '⚠️ - No Weather';
      textColor = Colors.white;
      subTextColor = Colors.white70;
      containerFill = Colors.black.withAlpha(35);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusBgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // District Name Header
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: textColor, size: 20),
              const SizedBox(width: 6),
              Text(
                districtName.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Weather status line
          Text(
            weatherText,
            style: TextStyle(fontSize: 13, color: textColor, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Date of Issue & Valid up to side-by-side
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: containerFill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, color: subTextColor, size: 12),
                          const SizedBox(width: 4),
                          Text('Date of Issue', style: TextStyle(fontSize: 10, color: subTextColor)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$issueDateStr $issueTimeStr',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: containerFill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.event_available_outlined, color: subTextColor, size: 12),
                          const SizedBox(width: 4),
                          Text('Valid up to', style: TextStyle(fontSize: 10, color: subTextColor)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$issueDateStr $validTimeStr',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Full-width status pill
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: containerFill,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusTitle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Interactive Map Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ImdMapScreen()),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: containerFill,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Interactive Map',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: textColor, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
