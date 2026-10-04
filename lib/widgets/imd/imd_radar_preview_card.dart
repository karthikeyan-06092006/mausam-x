import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/weather_provider.dart';
import '../../screens/imd_map_screen.dart';

class ImdRadarPreviewCard extends StatelessWidget {
  const ImdRadarPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context);
    final city = provider.selectedCity;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF135398).withAlpha(225),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF38BDF8).withAlpha(120)),
                  ),
                  child: const Icon(Icons.radar, color: Color(0xFF38BDF8), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'IMD Doppler Radar & Satellite',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Live precipitation & cloud scans near ${city.name}',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ImdMapScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Open Map'),
                      SizedBox(width: 4),
                      Icon(Icons.open_in_new, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Mini Visual Banner
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ImdMapScreen()),
              );
            },
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: Container(
              height: 110,
              width: double.infinity,
              margin: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFF001B3A), Color(0xFF003875), Color(0xFF00142A)],
                ),
                border: Border.all(color: const Color(0xFF38BDF8).withAlpha(60)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Radar Concentric Circles Graphic
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MiniRadarGridPainter(),
                    ),
                  ),

                  // Center Pin & City Text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withAlpha(60),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF38BDF8)),
                        ),
                        child: const Icon(Icons.my_location, color: Colors.white, size: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap to explore interactive Doppler scan around ${city.name}',
                        style: const TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
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

class _MiniRadarGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFF38BDF8).withAlpha(35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, 25, paint);
    canvas.drawCircle(center, 55, paint);
    canvas.drawCircle(center, 85, paint);

    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
