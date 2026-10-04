import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../models/aqi_data.dart';

class SevereAlertBanner extends StatelessWidget {
  final WeatherData weather;
  final AqiData? aqi;

  const SevereAlertBanner({
    super.key,
    required this.weather,
    this.aqi,
  });

  @override
  Widget build(BuildContext context) {
    String? alertTitle;
    String? alertMessage;
    Color alertColor = const Color(0xFFEF4444);

    if (weather.weatherCode >= 95) {
      alertTitle = 'IMD Thunderstorm / Lightning Warning';
      alertMessage = 'Severe convective storm activity active. Stay indoors and avoid open ground.';
    } else if (weather.precipitationProbability > 75 && weather.precipitation > 5.0) {
      alertTitle = 'IMD Heavy Rainfall / Waterlogging Alert';
      alertMessage = 'Intense precipitation expected. Low-lying urban areas may experience inundation.';
    } else if (aqi != null && aqi!.aqi >= 300) {
      alertTitle = 'Severe Air Quality Warning (AQI ${aqi!.aqi})';
      alertMessage = 'Air quality is Hazardous / Very Poor. Avoid all outdoor exertion; wear N95 mask.';
    } else if (weather.visibilityMeters < 200) {
      alertTitle = 'Dense Fog / Road Hazard Advisory';
      alertMessage = 'Visibility dropped below 200m. Major transit and flight delays likely.';
      alertColor = const Color(0xFFF59E0B);
    } else if (weather.currentTemp > 41) {
      alertTitle = 'IMD Heatwave Warning';
      alertMessage = 'Severe daytime heat stress. Avoid direct solar exposure between 12 PM - 3 PM.';
    }

    if (alertTitle == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: alertColor.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: alertColor.withAlpha(150), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: alertColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alertTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: alertColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  alertMessage!,
                  style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
