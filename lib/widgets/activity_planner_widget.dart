import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/activity_models.dart';
import '../providers/weather_provider.dart';

class ActivityPlannerWidget extends StatelessWidget {
  const ActivityPlannerWidget({super.key});

  IconData _getActivityIcon(String key) {
    switch (key) {
      case 'two_wheeler':
        return Icons.two_wheeler;
      case 'directions_run':
        return Icons.directions_run;
      case 'beach_access':
        return Icons.beach_access;
      case 'commute':
        return Icons.directions_car;
      case 'agriculture':
        return Icons.agriculture;
      case 'celebration':
        return Icons.celebration;
      case 'videocam':
        return Icons.flight;
      default:
        return Icons.sports;
    }
  }

  Color _getVerdictColor(FeasibilityVerdict verdict) {
    switch (verdict) {
      case FeasibilityVerdict.ideal:
        return const Color(0xFF10B981); // Emerald
      case FeasibilityVerdict.good:
        return const Color(0xFF38BDF8); // Sky Blue
      case FeasibilityVerdict.caution:
        return const Color(0xFFF59E0B); // Amber
      case FeasibilityVerdict.notRecommended:
        return const Color(0xFFEF4444); // Red
    }
  }

  IconData _getVerdictIcon(FeasibilityVerdict verdict) {
    switch (verdict) {
      case FeasibilityVerdict.ideal:
        return Icons.check_circle_outline;
      case FeasibilityVerdict.good:
        return Icons.thumb_up_alt_outlined;
      case FeasibilityVerdict.caution:
        return Icons.warning_amber_outlined;
      case FeasibilityVerdict.notRecommended:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context);
    final result = provider.feasibilityResult;
    final timeFormat = DateFormat('h:mm a');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withAlpha(40),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.bolt, color: Color(0xFF38BDF8), size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SMART ACTIVITY FEASIBILITY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            Text(
                              'Calculates Weather • Rain • AQI • Visibility',
                              style: TextStyle(fontSize: 11, color: Colors.white54),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Step 2 Live',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF334155), height: 1),

          // Activity Horizontal Selector
          Padding(
            padding: const EdgeInsets.only(top: 14.0, bottom: 6.0),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: ActivityInfo.supportedActivities.length,
                separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final act = ActivityInfo.supportedActivities[idx];
                  final isSel = act.type == provider.selectedActivity;

                  return ChoiceChip(
                    avatar: Icon(
                      _getActivityIcon(act.iconKey),
                      size: 16,
                      color: isSel ? Colors.white : const Color(0xFF94A3B8),
                    ),
                    label: Text(
                      act.title.split('/').first.trim(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        color: isSel ? Colors.white : Colors.white70,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: const Color(0xFF0284C7),
                    backgroundColor: const Color(0xFF0F172A),
                    side: BorderSide(
                      color: isSel ? const Color(0xFF38BDF8) : const Color(0xFF334155),
                    ),
                    onSelected: (selected) {
                      if (selected) provider.setActivity(act.type);
                    },
                  );
                },
              ),
            ),
          ),

          // Time Selector Quick Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Text(
                  'Target Time: ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTimeChip(
                          context,
                          label: 'Right Now',
                          time: DateTime.now(),
                          provider: provider,
                        ),
                        const SizedBox(width: 6),
                        _buildTimeChip(
                          context,
                          label: '+2 Hours',
                          time: DateTime.now().add(const Duration(hours: 2)),
                          provider: provider,
                        ),
                        const SizedBox(width: 6),
                        _buildTimeChip(
                          context,
                          label: '+4 Hours',
                          time: DateTime.now().add(const Duration(hours: 4)),
                          provider: provider,
                        ),
                        const SizedBox(width: 6),
                        _buildTimeChip(
                          context,
                          label: '+8 Hours',
                          time: DateTime.now().add(const Duration(hours: 8)),
                          provider: provider,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (result != null) ...[
            // Verdict Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getVerdictColor(result.verdict).withAlpha(25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getVerdictColor(result.verdict).withAlpha(120),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              _getVerdictIcon(result.verdict),
                              color: _getVerdictColor(result.verdict),
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                result.verdictTitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _getVerdictColor(result.verdict),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getVerdictColor(result.verdict),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${result.score}/100',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'At ${timeFormat.format(result.targetTime)}: ${result.summaryExplanation}',
                    style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.3),
                  ),
                ],
              ),
            ),

            // "Best Time Today" Smart Recommendation Box
            if (result.bestAlternativeSlot != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF065F46), Color(0xFF047857)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withAlpha(60),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Color(0xFFFDE047), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BEST TIME TODAY RECOMMENDED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: Color(0xFFD1FAE5),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            result.bestAlternativeSlot!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Positives and Warnings Checklist
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (result.positiveFactors.isNotEmpty) ...[
                    const Text(
                      'Favorable Conditions:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                    ),
                    const SizedBox(height: 4),
                    ...result.positiveFactors.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 3.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check, size: 14, color: Color(0xFF10B981)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(p, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 8),
                  ],
                  if (result.warningFactors.isNotEmpty) ...[
                    const Text(
                      'Risks & Warnings:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                    ),
                    const SizedBox(height: 4),
                    ...result.warningFactors.map((w) => Padding(
                          padding: const EdgeInsets.only(bottom: 3.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning, size: 14, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(w, style: const TextStyle(fontSize: 12, color: Color(0xFFFCD34D))),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),

            // 24-Hour Interactive Timeline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '24-Hour Feasibility Timeline (Tap any hour to test):',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: result.dayHourlySlots.length,
                      separatorBuilder: (ctx, idx) => const SizedBox(width: 6),
                      itemBuilder: (context, idx) {
                        final slot = result.dayHourlySlots[idx];
                        final isSlotSelected = slot.time.hour == provider.selectedActivityTime.hour;
                        final color = _getVerdictColor(slot.verdict);

                        return InkWell(
                          onTap: () => provider.setActivityTime(slot.time),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 58,
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSlotSelected ? color.withAlpha(60) : const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSlotSelected ? color : const Color(0xFF334155),
                                width: isSlotSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  DateFormat('ha').format(slot.time).toLowerCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSlotSelected ? FontWeight.bold : FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${slot.score}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${slot.temp.round()}°',
                                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeChip(
    BuildContext context, {
    required String label,
    required DateTime time,
    required WeatherProvider provider,
  }) {
    final isSelected = time.hour == provider.selectedActivityTime.hour;
    return InkWell(
      onTap: () => provider.setActivityTime(time),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF334155),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }
}
