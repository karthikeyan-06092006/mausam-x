import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/weather_data.dart';

class ImdSunMoonCard extends StatelessWidget {
  final WeatherData weather;

  const ImdSunMoonCard({super.key, required this.weather});

  int _parseTimeToMinutes(String timeStr, int fallbackMinutes) {
    try {
      final clean = timeStr.contains('T') ? timeStr.split('T').last : timeStr;
      final parts = clean.trim().split(':');
      if (parts.length >= 2) {
        final h = int.parse(parts[0]);
        final m = int.parse(parts[1].substring(0, min(2, parts[1].length)));
        return h * 60 + m;
      }
    } catch (_) {}
    return fallbackMinutes;
  }

  String _formatMinutesToIST(int minutes) {
    final h = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} IST';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;

    final sunriseTimeStr = weather.sunrise.contains('T')
        ? weather.sunrise.split('T').last
        : (weather.sunrise.isNotEmpty ? weather.sunrise : '06:05');
    final sunsetTimeStr = weather.sunset.contains('T')
        ? weather.sunset.split('T').last
        : (weather.sunset.isNotEmpty ? weather.sunset : '18:15');

    final sunriseMin = _parseTimeToMinutes(weather.sunrise, 365);
    final sunsetMin = _parseTimeToMinutes(weather.sunset, 1095);

    // 1. DYNAMIC SUN PROGRESS (0.0 at sunrise, 0.5 at zenith noon, 1.0 at sunset)
    double sunProgress;
    if (nowMin <= sunriseMin) {
      sunProgress = 0.0;
    } else if (nowMin >= sunsetMin) {
      sunProgress = 1.0;
    } else {
      sunProgress = ((nowMin - sunriseMin) / (sunsetMin - sunriseMin)).clamp(0.0, 1.0);
    }

    // 2. DYNAMIC MOON PROGRESS & ASTRONOMICAL LUNAR CYCLE
    final daysSinceEpoch = now.difference(DateTime(2000, 1, 6, 18, 14)).inMinutes / 1440.0;
    final synodicPhase = (daysSinceEpoch % 29.530588853);
    final moonriseMin = ((synodicPhase / 29.530588853) * 1440).round() % 1440;
    final moonsetMin = (moonriseMin + 740) % 1440;

    double moonProgress;
    if (moonsetMin > moonriseMin) {
      if (nowMin < moonriseMin) {
        moonProgress = 0.0;
      } else if (nowMin > moonsetMin) {
        moonProgress = 1.0;
      } else {
        moonProgress = ((nowMin - moonriseMin) / (moonsetMin - moonriseMin)).clamp(0.0, 1.0);
      }
    } else {
      // Over midnight wrap
      final totalMoonVisibleMin = (1440 - moonriseMin) + moonsetMin;
      if (nowMin >= moonriseMin) {
        moonProgress = ((nowMin - moonriseMin) / totalMoonVisibleMin).clamp(0.0, 1.0);
      } else if (nowMin <= moonsetMin) {
        moonProgress = (((1440 - moonriseMin) + nowMin) / totalMoonVisibleMin).clamp(0.0, 1.0);
      } else {
        moonProgress = (nowMin - moonsetMin) < (moonriseMin - nowMin) ? 1.0 : 0.0;
      }
    }

    final moonriseDisplay = _formatMinutesToIST(moonriseMin);
    final moonsetDisplay = _formatMinutesToIST(moonsetMin);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Sun Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF135398).withAlpha(190),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withAlpha(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.wb_sunny_outlined, color: Colors.white70, size: 16),
                      SizedBox(width: 6),
                      Text('Sun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Sun Arc Graphic
                  Center(
                    child: SizedBox(
                      width: 110,
                      height: 55,
                      child: CustomPaint(
                        painter: _ArcPainter(
                          progress: sunProgress,
                          arcColor: const Color(0xFFF59E0B),
                          indicatorColor: const Color(0xFFFBBF24),
                          isSun: true,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Sunrise & Sunset Labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$sunriseTimeStr IST', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('$sunsetTimeStr IST', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Moon Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF135398).withAlpha(190),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withAlpha(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.nightlight_round_outlined, color: Colors.white70, size: 16),
                      SizedBox(width: 6),
                      Text('Moon', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Moon Arc Graphic
                  Center(
                    child: SizedBox(
                      width: 110,
                      height: 55,
                      child: CustomPaint(
                        painter: _ArcPainter(
                          progress: moonProgress,
                          arcColor: const Color(0xFF818CF8),
                          indicatorColor: Colors.white,
                          isSun: false,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Moonrise & Moonset Labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(moonriseDisplay, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(moonsetDisplay, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color arcColor;
  final Color indicatorColor;
  final bool isSun;

  const _ArcPainter({
    required this.progress,
    required this.arcColor,
    required this.indicatorColor,
    required this.isSun,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    final paint = Paint()
      ..color = arcColor.withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Draw background semicircle
    canvas.drawArc(rect, pi, pi, false, paint);

    // Draw progress arc with brighter color
    final progressPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final sweepAngle = pi * progress;
    canvas.drawArc(rect, pi, sweepAngle, false, progressPaint);

    // Calculate indicator position along arc
    final angle = pi + sweepAngle;
    final radiusX = size.width / 2;
    final radiusY = size.height;
    final centerX = size.width / 2;
    final centerY = size.height;

    final indX = centerX + radiusX * cos(angle);
    final indY = centerY + radiusY * sin(angle);

    // Draw indicator (sun glow or moon dot)
    final dotPaint = Paint()..color = indicatorColor;
    canvas.drawCircle(Offset(indX, indY), isSun ? 5.5 : 4.5, dotPaint);

    if (isSun) {
      final glowPaint = Paint()
        ..color = indicatorColor.withAlpha(90)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(indX, indY), 9.0, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
