import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../models/weather_data.dart';

class ImdHeroWeather extends StatelessWidget {
  final WeatherData weather;

  const ImdHeroWeather({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final updateTimeStr = DateFormat('hh:mm a').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Big Temperature & Atmospheric stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.currentTemp.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                    ),
                    const Text(
                      '°c',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Updated At  $updateTimeStr',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Feels Like  ${weather.apparentTemp.toStringAsFixed(1)}°c',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.water_drop, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${weather.relativeHumidity}%',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right: Physical & Meteorological Wind Compass Dial
          WindCompassDial(
            windSpeedKmH: weather.windSpeed,
            windDirectionDeg: weather.windDirection,
          ),
        ],
      ),
    );
  }
}

class WindCompassDial extends StatefulWidget {
  final double windSpeedKmH;
  final int windDirectionDeg;

  const WindCompassDial({
    super.key,
    required this.windSpeedKmH,
    required this.windDirectionDeg,
  });

  @override
  State<WindCompassDial> createState() => _WindCompassDialState();
}

class _WindCompassDialState extends State<WindCompassDial> {
  StreamSubscription<MagnetometerEvent>? _magSubscription;
  double _deviceHeadingDeg = 0.0;
  double _manualDragAngleDeg = 0.0;
  int _lastEventMs = 0;

  @override
  void initState() {
    super.initState();
    _startMagnetometerListener();
  }

  void _startMagnetometerListener() {
    try {
      _magSubscription = magnetometerEventStream().listen(
        (MagnetometerEvent event) {
          final nowMs = DateTime.now().millisecondsSinceEpoch;
          if (nowMs - _lastEventMs < 100) return; // ~10fps smoothing
          _lastEventMs = nowMs;

          // Standard Android/iOS magnetometer coordinates:
          // X: right, Y: top of screen. Heading angle clockwise from +Y (North):
          final rawRad = atan2(-event.x, event.y);
          double rawDeg = rawRad * (180 / pi);
          if (rawDeg < 0) rawDeg += 360;

          // Angular low-pass filter to eliminate jitter
          double diff = rawDeg - _deviceHeadingDeg;
          while (diff < -180) {
            diff += 360;
          }
          while (diff > 180) {
            diff -= 360;
          }

          if (diff.abs() > 0.5 && mounted) {
            setState(() {
              _deviceHeadingDeg = (_deviceHeadingDeg + diff * 0.22) % 360;
              if (_deviceHeadingDeg < 0) _deviceHeadingDeg += 360;
            });
          }
        },
        onError: (_) {},
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _magSubscription?.cancel();
    super.dispose();
  }

  static String getCardinalDirection(int deg) {
    const directions = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    final index = ((deg + 11.25) % 360 / 22.5).floor();
    return directions[index % 16];
  }

  static String getBeaufortScale(double speedKmH) {
    if (speedKmH < 2) return 'Calm';
    if (speedKmH <= 5) return 'Light Air';
    if (speedKmH <= 11) return 'Light Breeze';
    if (speedKmH <= 19) return 'Gentle Breeze';
    if (speedKmH <= 28) return 'Moderate Breeze';
    if (speedKmH <= 38) return 'Fresh Breeze';
    if (speedKmH <= 49) return 'Strong Breeze';
    if (speedKmH <= 61) return 'High Wind / Near Gale';
    return 'Gale Alert / Severe Wind';
  }

  void _showWindDetails(BuildContext context) {
    final cardinal = getCardinalDirection(widget.windDirectionDeg);
    final beaufort = getBeaufortScale(widget.windSpeedKmH);
    final knots = (widget.windSpeedKmH * 0.539957).toStringAsFixed(1);
    final ms = (widget.windSpeedKmH / 3.6).toStringAsFixed(1);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF00224D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withAlpha(50),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF38BDF8)),
                    ),
                    child: const Icon(Icons.explore, color: Color(0xFF38BDF8), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('IMD METEOROLOGICAL COMPASS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Surface Wind Vector & Anemometer Data', style: TextStyle(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF001833),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatTile('Wind Speed', '${widget.windSpeedKmH.toStringAsFixed(1)} km/h', '$knots kt • $ms m/s'),
                        _buildStatTile('Direction', '$cardinal (${widget.windDirectionDeg}°)', 'Blowing towards ${(widget.windDirectionDeg + 180) % 360}°'),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatTile('Beaufort State', beaufort, 'Surface Wind Classification'),
                        _buildStatTile('Device Heading', '${_deviceHeadingDeg.round()}° Azimuth', 'Hardware Magnetometer'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'Rotate your phone in 3D space to align the compass dial with True North.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatTile(String title, String val, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.white60)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 1),
        Text(sub, style: const TextStyle(fontSize: 10, color: Color(0xFF38BDF8))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCompassAngleDeg = _deviceHeadingDeg + _manualDragAngleDeg;
    final compassAngleRad = (totalCompassAngleDeg * pi) / 180;
    final windArrowAngleRad = ((widget.windDirectionDeg - totalCompassAngleDeg) * pi) / 180;
    final cardinal = getCardinalDirection(widget.windDirectionDeg);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => _showWindDetails(context),
        onPanUpdate: (details) {
          setState(() {
            _manualDragAngleDeg += details.delta.dx * 0.8;
          });
        },
        child: Tooltip(
          message: 'Tap for Wind & Compass details (${widget.windSpeedKmH.round()} km/h $cardinal)',
          child: Container(
            width: 145,
            height: 145,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF001B3A).withAlpha(180),
              border: Border.all(color: const Color(0xFF38BDF8).withAlpha(60), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(80),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. ROTATING COMPASS RING (Tracks Phone Heading)
                Transform.rotate(
                  angle: -compassAngleRad,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(145, 145),
                        painter: _CompassTicksPainter(),
                      ),
                      // North Marker (IMD Red)
                      const Positioned(
                        top: 7,
                        child: Text(
                          'N',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFEF4444), // Highlighted Red
                          ),
                        ),
                      ),
                      // South
                      const Positioned(
                        bottom: 7,
                        child: Text(
                          'S',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      // West
                      const Positioned(
                        left: 7,
                        child: Text(
                          'W',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      // East
                      const Positioned(
                        right: 7,
                        child: Text(
                          'E',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. METEOROLOGICAL WIND DIRECTION ARROW
                Transform.rotate(
                  angle: windArrowAngleRad,
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Wind Arrow Head (Direction of incoming wind)
                        Positioned(
                          top: 4,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 0,
                                height: 0,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFF38BDF8), width: 12),
                                    left: BorderSide(color: Colors.transparent, width: 7),
                                    right: BorderSide(color: Colors.transparent, width: 7),
                                  ),
                                ),
                              ),
                              Container(
                                width: 2.5,
                                height: 16,
                                color: const Color(0xFF38BDF8),
                              ),
                            ],
                          ),
                        ),
                        // Wind Tail Dot
                        Positioned(
                          bottom: 12,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(160),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. CENTER SPEED & DIRECTION DISPLAY
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00224D),
                    border: Border.all(color: const Color(0xFF38BDF8).withAlpha(120), width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.windSpeedKmH.round().toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      const Text(
                        'km/h',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        cardinal,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF38BDF8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompassTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final minorPaint = Paint()
      ..color = Colors.white.withAlpha(90)
      ..strokeWidth = 1.0;
    final majorPaint = Paint()
      ..color = Colors.white.withAlpha(180)
      ..strokeWidth = 1.8;

    for (int i = 0; i < 36; i++) {
      final angle = (i * 10 * pi) / 180;
      final isCardinal = i % 9 == 0;
      final isMajor = i % 3 == 0;
      final tickLength = isCardinal ? 7.0 : (isMajor ? 5.0 : 3.0);
      final p = isMajor ? majorPaint : minorPaint;

      final startX = center.dx + (radius - 3) * cos(angle);
      final startY = center.dy + (radius - 3) * sin(angle);
      final endX = center.dx + (radius - 3 - tickLength) * cos(angle);
      final endY = center.dy + (radius - 3 - tickLength) * sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
