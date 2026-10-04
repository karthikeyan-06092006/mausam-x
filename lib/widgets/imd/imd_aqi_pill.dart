import 'package:flutter/material.dart';
import '../../models/aqi_data.dart';

class ImdAqiPill extends StatelessWidget {
  final AqiData? aqiData;

  const ImdAqiPill({super.key, this.aqiData});

  Color _getCategoryBgColor(int val) {
    if (val <= 50) return const Color(0xFF22C55E); // Green
    if (val <= 100) return const Color(0xFF84CC16); // Light green / Satisfactory
    if (val <= 200) return const Color(0xFFFBBF24); // Moderate Yellow
    if (val <= 300) return const Color(0xFFF97316); // Orange
    if (val <= 400) return const Color(0xFFEF4444); // Red
    return const Color(0xFF7F1D1D); // Maroon
  }

  @override
  Widget build(BuildContext context) {
    final aqi = aqiData?.aqi ?? 68;
    final category = aqiData?.aqiCategory.split('/').first.trim() ?? 'Satisfactory';
    final categoryColor = _getCategoryBgColor(aqi);

    return Column(
      children: [
        // Pill container
        Container(
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Left half: AQI number
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(7)),
                ),
                child: Text(
                  'AQI $aqi',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Right half: Category
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // Subtext CPCB tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF003875).withAlpha(180),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'National AQI-Source-CPCB',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
