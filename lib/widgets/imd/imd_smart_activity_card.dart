import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/activity_models.dart';
import '../../providers/weather_provider.dart';

class ImdSmartActivityCard extends StatefulWidget {
  const ImdSmartActivityCard({super.key});

  @override
  State<ImdSmartActivityCard> createState() => _ImdSmartActivityCardState();
}

class _ImdSmartActivityCardState extends State<ImdSmartActivityCard> {
  bool _showWhyBestOnLanding = true;
  bool _showSuggestedTime = false;

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
        return const Color(0xFF10B981);
      case FeasibilityVerdict.good:
        return const Color(0xFF38BDF8);
      case FeasibilityVerdict.caution:
        return const Color(0xFFF59E0B);
      case FeasibilityVerdict.notRecommended:
        return const Color(0xFFEF4444);
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFF38BDF8);
    if (score >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Future<void> _openClockTimePicker(BuildContext context, WeatherProvider provider) async {
    final initial = TimeOfDay.fromDateTime(provider.selectedActivityTime);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF38BDF8),
              onPrimary: Colors.black,
              surface: Color(0xFF003875),
              onSurface: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF002A5A),
              dialBackgroundColor: const Color(0xFF001A38),
              dialHandColor: const Color(0xFF38BDF8),
              hourMinuteColor: const Color(0xFF001A38),
              hourMinuteTextColor: Colors.white,
              dayPeriodColor: const Color(0xFF001A38),
              dayPeriodTextColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final now = DateTime.now();
      final newTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      provider.setActivityTime(newTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context);
    final result = provider.feasibilityResult;
    final isCheckingOther = provider.isActivityCardExpanded;
    final currentActivity = ActivityInfo.getByType(provider.selectedActivity);
    final targetTime = provider.selectedActivityTime;

    if (result == null) return const SizedBox.shrink();

    final timeFormatNow = DateFormat('h:mm a');
    final hourFormat = DateFormat('hh');
    final minuteFormat = DateFormat('mm');
    final amPmFormat = DateFormat('a');

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
      child: isCheckingOther
          // =========================================================
          // VIEW 2: ACTIVITY SELECTION PART (ONLY when user clicks)
          // =========================================================
          ? _buildManualActivityChecker(
              context: context,
              provider: provider,
              result: result,
              currentActivity: currentActivity,
              targetTime: targetTime,
              timeFormatNow: timeFormatNow,
              hourFormat: hourFormat,
              minuteFormat: minuteFormat,
              amPmFormat: amPmFormat,
            )
          // =========================================================
          // VIEW 1: LANDING PAGE RECOMMENDATION PART (as in image)
          // =========================================================
          : _buildLandingRecommendationCard(
              context: context,
              provider: provider,
              result: result,
              timeFormatNow: timeFormatNow,
            ),
    );
  }

  // =========================================================================
  // 1. LANDING PAGE RECOMMENDATION VIEW
  // =========================================================================
  Widget _buildLandingRecommendationCard({
    required BuildContext context,
    required WeatherProvider provider,
    required ActivityFeasibilityResult result,
    required DateFormat timeFormatNow,
  }) {
    final isFavorable = result.isAnyActivityFavorableNow && result.recommendedActivityNow != null;

    if (!isFavorable) {
      // If NO activity is suitable right now due to rain/darkness/AQI
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withAlpha(40),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFF59E0B).withAlpha(140)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 13),
                      const SizedBox(width: 4),
                      Text(
                        'WEATHER CAUTION (${timeFormatNow.format(DateTime.now())})',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFF59E0B),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => provider.setActivityCardExpanded(true),
                  child: const Row(
                    children: [
                      Text(
                        'Check Times',
                        style: TextStyle(fontSize: 11, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.chevron_right, color: Color(0xFF38BDF8), size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withAlpha(35),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF59E0B).withAlpha(120)),
                  ),
                  child: const Icon(Icons.cloud_off, color: Color(0xFFF59E0B), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'No Outdoor Activities Recommended Right Now',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.recommendedReasonNow,
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => provider.setActivityCardExpanded(true),
                icon: const Icon(Icons.access_time_filled, size: 15),
                label: const Text('Check Upcoming Favorable Time Slots'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF38BDF8),
                  side: const BorderSide(color: Color(0xFF38BDF8)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final recActivity = result.recommendedActivityNow!;
    final recScoreColor = _getScoreColor(result.recommendedScoreNow);

    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Subheader Tag & Toggle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF38BDF8).withAlpha(120)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'BEST SUITED FOR NOW (${timeFormatNow.format(DateTime.now())})',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF38BDF8),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  setState(() {
                    _showWhyBestOnLanding = !_showWhyBestOnLanding;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      _showWhyBestOnLanding ? 'Hide' : 'Why best?',
                      style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                    Icon(
                      _showWhyBestOnLanding ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Recommended Activity Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: recScoreColor.withAlpha(45),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: recScoreColor.withAlpha(140)),
                ),
                child: Icon(
                  _getActivityIcon(recActivity.iconKey),
                  color: recScoreColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            recActivity.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: recScoreColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${result.recommendedScoreNow}/100',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.recommendedReasonNow,
                      style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Collapsible "Why is [Activity] Best Right Now?" Checklist
          if (_showWhyBestOnLanding && result.recommendedPositivesNow.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00224D).withAlpha(175),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF38BDF8), size: 15),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Why is ${recActivity.title.split('/').first.trim()} Best Right Now?',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF38BDF8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...result.recommendedPositivesNow.map(
                    (pos) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF34D399)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              pos,
                              style: const TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Button to enter custom activity checker
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () => provider.setActivityCardExpanded(true),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF002855),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF38BDF8).withAlpha(90)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.tune_rounded, color: Color(0xFF38BDF8), size: 15),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Check Another Activity / Test Different Time >',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. MANUAL ACTIVITY SELECTION & TIME EVALUATOR VIEW
  // =========================================================================
  Widget _buildManualActivityChecker({
    required BuildContext context,
    required WeatherProvider provider,
    required ActivityFeasibilityResult result,
    required ActivityInfo currentActivity,
    required DateTime targetTime,
    required DateFormat timeFormatNow,
    required DateFormat hourFormat,
    required DateFormat minuteFormat,
    required DateFormat amPmFormat,
  }) {
    final evalVerdictColor = _getVerdictColor(result.verdict);
    final isHighRisk = result.verdict == FeasibilityVerdict.notRecommended || result.score < 40;
    final isCaution = !isHighRisk && (result.verdict == FeasibilityVerdict.caution || result.score < 70 || result.warningFactors.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Navigation Bar (Back to Recommendation)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded, color: Color(0xFF38BDF8), size: 16),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Check Activity / Time:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => provider.setActivityCardExpanded(false),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, color: Colors.white70, size: 13),
                      SizedBox(width: 4),
                      Text('Close', style: TextStyle(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Activity Dropdown Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF002855),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ActivityType>(
                value: provider.selectedActivity,
                isExpanded: true,
                dropdownColor: const Color(0xFF002855),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                items: ActivityInfo.supportedActivities.map((act) {
                  return DropdownMenuItem<ActivityType>(
                    value: act.type,
                    child: Row(
                      children: [
                        Icon(_getActivityIcon(act.iconKey), color: const Color(0xFF38BDF8), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            act.title,
                            style: const TextStyle(fontSize: 13, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    provider.setActivity(val);
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Target Time Header + Reset Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.access_time_filled, color: Color(0xFF38BDF8), size: 15),
                  SizedBox(width: 6),
                  Text(
                    'Time to Test:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                ],
              ),
              if (targetTime.difference(DateTime.now()).inMinutes.abs() > 3)
                Flexible(
                  child: InkWell(
                    onTap: () => provider.setActivityTime(DateTime.now()),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withAlpha(35),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF38BDF8).withAlpha(100)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, color: Color(0xFF38BDF8), size: 12),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Reset to Now',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Glowing Digital Clock Display Card (Tap to set custom time)
          InkWell(
            onTap: () => _openClockTimePicker(context, provider),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF001F44),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF38BDF8).withAlpha(120), width: 1.2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDigitBox(hourFormat.format(targetTime)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          ':',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                        ),
                      ),
                      _buildDigitBox(minuteFormat.format(targetTime)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          amPmFormat.format(targetTime),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app, size: 11, color: Colors.white54),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Tap clock to set time (Defaults to Current Time)',
                          style: TextStyle(fontSize: 10.5, color: Colors.white54),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // =========================================================
          // EVALUATED ACTIVITY RESULT CARD
          // =========================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: evalVerdictColor.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: evalVerdictColor.withAlpha(120)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_getActivityIcon(currentActivity.iconKey), color: evalVerdictColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${currentActivity.title.split('/').first.trim()} @ ${timeFormatNow.format(targetTime)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: evalVerdictColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${result.score}/100',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // ---------------------------------------------------
                // CASE 1: HIGH RISK (Score < 40 or fatal dealbreakers)
                // ---------------------------------------------------
                if (isHighRisk) ...[
                  Text(
                    '❌ Not Suitable: High risk weather for ${currentActivity.title.split('/').first.trim()} at this time.',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFCA5A5), height: 1.25),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withAlpha(35),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFEF4444).withAlpha(100)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cancel, color: Color(0xFFF87171), size: 13),
                        SizedBox(width: 4),
                        Text(
                          'HIGH RISK FACTORS',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFFCA5A5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...result.warningFactors.map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.close_rounded, size: 14, color: Color(0xFFF87171)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              w,
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFFFEE2E2), height: 1.25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
                // ---------------------------------------------------
                // CASE 2: MODERATE / CAUTION (Score 40-69)
                // ---------------------------------------------------
                else if (isCaution) ...[
                  Text(
                    '⚠️ Moderate Weather: Follow precautions for ${currentActivity.title.split('/').first.trim()}.',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFCD34D), height: 1.25),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withAlpha(35),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFF59E0B).withAlpha(100)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFFBBF24), size: 13),
                        SizedBox(width: 4),
                        Text(
                          'PRECAUTIONS & ADVISORY',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFFCD34D)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...result.warningFactors.map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, size: 14, color: Color(0xFFFBBF24)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              w,
                              style: const TextStyle(fontSize: 11.5, color: Colors.white, height: 1.25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
                // ---------------------------------------------------
                // CASE 3: FAVORABLE / PERFECT (Score >= 70)
                // ---------------------------------------------------
                else ...[
                  Text(
                    '🎉 Perfect Weather for ${currentActivity.title.split('/').first.trim()}! Optimal conditions.',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF34D399), height: 1.25),
                  ),
                  const SizedBox(height: 8),
                  if (result.positiveFactors.isNotEmpty) ...[
                    const Text(
                      'WHY IT IS GREAT:',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF6EE7B7)),
                    ),
                    const SizedBox(height: 6),
                    ...result.positiveFactors.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF34D399)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(p, style: const TextStyle(fontSize: 11.5, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),

          // =========================================================
          // SUGGESTED BEST TIME SLOT SECTION (Catchy Expandable Button)
          // =========================================================
          if (result.bestAlternativeSlot != null) ...[
            const SizedBox(height: 12),
            if (!_showSuggestedTime)
              InkWell(
                onTap: () {
                  setState(() => _showSuggestedTime = true);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF047857), Color(0xFF065F46)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF34D399).withAlpha(160), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF047857).withAlpha(100),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: Color(0xFFFBBF24), size: 16),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'View Suggested Best Time Slot',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B).withAlpha(200),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF34D399).withAlpha(140), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Color(0xFFFBBF24), size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Best Time (${currentActivity.title.split('/').first.trim()}):',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF34D399),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${result.bestAlternativeScore}/100',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black87),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            setState(() => _showSuggestedTime = false);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Hide', style: TextStyle(fontSize: 10.5, color: Colors.white70)),
                                Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white70, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '🏆 ${result.bestAlternativeSlot!}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF34D399)),
                    ),
                    if (result.bestAlternativeReason != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        result.bestAlternativeReason!,
                        style: const TextStyle(fontSize: 11.5, color: Colors.white70, height: 1.25),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDigitBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF00142A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF38BDF8).withAlpha(80)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
