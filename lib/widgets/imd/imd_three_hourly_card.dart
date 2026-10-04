import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/weather_data.dart';

class ImdThreeHourlyCard extends StatelessWidget {
  final List<HourlyWeather> hourlyList;

  const ImdThreeHourlyCard({super.key, required this.hourlyList});

  IconData _getConditionIcon(int code) {
    if (code == 0) return Icons.wb_sunny_outlined;
    if (code == 1 || code == 2) return Icons.wb_cloudy_outlined;
    if (code == 3) return Icons.cloud_outlined;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 67) return Icons.water_drop_outlined;
    if (code >= 80) return Icons.grain;
    return Icons.wb_cloudy_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Find starting index from current hour
    int startIndex = 0;
    for (int i = 0; i < hourlyList.length; i++) {
      if (hourlyList[i].time.isAfter(now.subtract(const Duration(minutes: 59)))) {
        startIndex = i;
        break;
      }
    }

    final List<HourlyWeather> slots = [];
    for (int i = startIndex; i < hourlyList.length; i += 3) {
      if (slots.length < 3) slots.add(hourlyList[i]);
    }
    if (slots.isEmpty && hourlyList.isNotEmpty) {
      slots.add(hourlyList.last);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF135398).withAlpha(190), // Translucent card background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(40)),
      ),
      child: Column(
        children: [
          // 3 Columns Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: slots.map((item) {
              final dateStr = DateFormat('dd MMMM').format(item.time);
              final timeStr = DateFormat('HH:mm').format(item.time);

              return Expanded(
                child: Column(
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Icon(_getConditionIcon(item.weatherCode), color: Colors.white, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      item.weatherCondition,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.temperature.toStringAsFixed(1)}°c',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.water_drop, color: Colors.white70, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${item.humidity}%',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // 3-Hourly Button
          InkWell(
            onTap: () => _showAllThreeHourlyModal(context, startIndex),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '3-Hourly',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllThreeHourlyModal(BuildContext context, int startIndex) {
    final List<HourlyWeather> all3hSlots = [];
    for (int i = startIndex; i < hourlyList.length; i += 3) {
      all3hSlots.add(hourlyList[i]);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF00224D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
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
              const Text(
                '3-HOURLY METEOROLOGICAL FORECAST',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              const Text(
                'Next 48-Hour Interval Predictions',
                style: TextStyle(fontSize: 11, color: Color(0xFF38BDF8)),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: all3hSlots.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, idx) {
                    final item = all3hSlots[idx];
                    final dateStr = DateFormat('EEE, dd MMM').format(item.time);
                    final timeStr = DateFormat('hh:mm a').format(item.time);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          Icon(_getConditionIcon(item.weatherCode), color: const Color(0xFF38BDF8), size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  timeStr,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Text(
                                  dateStr,
                                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            item.weatherCondition,
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${item.temperature.toStringAsFixed(1)}°C',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                '💧 ${item.humidity}%',
                                style: const TextStyle(fontSize: 11, color: Colors.white60),
                              ),
                            ],
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
      },
    );
  }
}
