import 'dart:math';
import 'package:intl/intl.dart';
import '../models/activity_models.dart';
import '../models/weather_data.dart';
import '../models/aqi_data.dart';

class ActivityScoringEngine {
  /// Evaluates an activity for a specific target time or scans the full day
  static ActivityFeasibilityResult evaluateActivity({
    required ActivityInfo activity,
    required DateTime targetTime,
    required WeatherData weatherData,
    required AqiData aqiData,
  }) {
    final List<HourlyFeasibilitySlot> slots = [];
    final hourlyForecast = weatherData.hourlyForecast;
    final hourlyAqi = aqiData.hourlyAqi;
    final now = DateTime.now();

    HourlyFeasibilitySlot? selectedSlot;

    // 1. Populate 24-hour slots for timeline
    for (int i = 0; i < min(24, hourlyForecast.length); i++) {
      final hw = hourlyForecast[i];
      final ha = (i < hourlyAqi.length)
          ? hourlyAqi[i]
          : HourlyAqi(
              time: hw.time,
              aqi: aqiData.aqi,
              pm2_5: aqiData.pm2_5,
              pm10: aqiData.pm10,
              uvIndex: hw.uvIndex,
            );

      final scoreResult = _calculateScore(
        activity: activity,
        slotTime: hw.time,
        temp: hw.temperature,
        rainProb: hw.precipitationProbability,
        rainMm: hw.precipitation,
        humidity: hw.humidity,
        visibilityM: hw.visibilityMeters,
        windSpeed: hw.windSpeed,
        uv: hw.uvIndex,
        aqi: ha.aqi,
      );

      final slot = HourlyFeasibilitySlot(
        time: hw.time,
        score: scoreResult.score,
        verdict: scoreResult.verdict,
        temp: hw.temperature,
        rainProb: hw.precipitationProbability,
        aqi: ha.aqi,
        visibilityKm: hw.visibilityMeters / 1000.0,
        windSpeed: hw.windSpeed,
      );

      slots.add(slot);

      // Match target time by hour
      if (hw.time.hour == targetTime.hour && (hw.time.day == targetTime.day || targetTime.difference(hw.time).inHours.abs() < 24)) {
        selectedSlot = slot;
      }
    }

    // Default selected slot if not strictly matched
    selectedSlot ??= slots.isNotEmpty ? slots.first : HourlyFeasibilitySlot(
      time: targetTime,
      score: 50,
      verdict: FeasibilityVerdict.caution,
      temp: weatherData.currentTemp,
      rainProb: weatherData.precipitationProbability,
      aqi: aqiData.aqi,
      visibilityKm: weatherData.visibilityMeters / 1000.0,
      windSpeed: weatherData.windSpeed,
    );

    // 2. Scan UPCOMING hours (from now onward, up to 72 hours) for the best future time slot
    HourlyFeasibilitySlot? bestUpcomingSlot;
    int highestScoreUpcoming = -1;

    for (int i = 0; i < hourlyForecast.length; i++) {
      final hw = hourlyForecast[i];
      // Only upcoming hours (not past)
      if (hw.time.isBefore(now.subtract(const Duration(minutes: 30)))) continue;

      final ha = (i < hourlyAqi.length)
          ? hourlyAqi[i]
          : HourlyAqi(
              time: hw.time,
              aqi: aqiData.aqi,
              pm2_5: aqiData.pm2_5,
              pm10: aqiData.pm10,
              uvIndex: hw.uvIndex,
            );

      final scoreResult = _calculateScore(
        activity: activity,
        slotTime: hw.time,
        temp: hw.temperature,
        rainProb: hw.precipitationProbability,
        rainMm: hw.precipitation,
        humidity: hw.humidity,
        visibilityM: hw.visibilityMeters,
        windSpeed: hw.windSpeed,
        uv: hw.uvIndex,
        aqi: ha.aqi,
      );

      final isWithinActiveHours = hw.time.hour >= activity.activeStartHour && hw.time.hour <= activity.activeEndHour;
      if (isWithinActiveHours && scoreResult.score > highestScoreUpcoming) {
        highestScoreUpcoming = scoreResult.score;
        bestUpcomingSlot = HourlyFeasibilitySlot(
          time: hw.time,
          score: scoreResult.score,
          verdict: scoreResult.verdict,
          temp: hw.temperature,
          rainProb: hw.precipitationProbability,
          aqi: ha.aqi,
          visibilityKm: hw.visibilityMeters / 1000.0,
          windSpeed: hw.windSpeed,
        );
      }
    }

    // Generate detailed feedback for the selected slot
    final detailedFeedback = _generateDetailedReasons(
      activity: activity,
      slot: selectedSlot,
      weatherData: weatherData,
      aqiData: aqiData,
    );

    // Compute intelligent "Best Time Window" with Date formatting
    final timeFormatter = DateFormat('h:mm a');
    String? bestAltWindow;
    int bestAltScore = 0;
    String? bestAltReason;

    if (bestUpcomingSlot != null) {
      final slotDate = DateTime(bestUpcomingSlot.time.year, bestUpcomingSlot.time.month, bestUpcomingSlot.time.day);
      final nowDate = DateTime(now.year, now.month, now.day);
      final dayDiff = slotDate.difference(nowDate).inDays;

      final startStr = timeFormatter.format(bestUpcomingSlot.time);
      final endStr = timeFormatter.format(bestUpcomingSlot.time.add(const Duration(hours: 2)));

      if (dayDiff == 0) {
        // Today
        if ((bestUpcomingSlot.time.hour - now.hour).abs() <= 1 &&
            (bestUpcomingSlot.score - selectedSlot.score).abs() <= 5 &&
            selectedSlot.score >= 70) {
          bestAltWindow = 'Today, $startStr – $endStr (Current Window)';
          bestAltReason = 'Right now is already the peak favorable window today for ${activity.title.split('/').first.trim()} (${selectedSlot.score}/100).';
        } else {
          bestAltWindow = 'Today, $startStr – $endStr';
          bestAltReason = 'Peak upcoming slot today: ${bestUpcomingSlot.temp.toStringAsFixed(1)}°C, ${bestUpcomingSlot.rainProb.round()}% rain risk, and safe winds (${bestUpcomingSlot.windSpeed.toStringAsFixed(1)} km/h).';
        }
      } else if (dayDiff == 1) {
        // Tomorrow
        final dateStr = DateFormat('dd MMM').format(bestUpcomingSlot.time);
        bestAltWindow = 'Tomorrow, $dateStr ($startStr – $endStr)';
        bestAltReason = 'Optimal upcoming slot tomorrow ($dateStr): ${bestUpcomingSlot.temp.toStringAsFixed(1)}°C, ${bestUpcomingSlot.rainProb.round()}% rain risk, and clear weather.';
      } else {
        // 2+ days later
        final dayName = DateFormat('EEE, dd MMM').format(bestUpcomingSlot.time);
        bestAltWindow = '$dayName ($startStr – $endStr)';
        bestAltReason = 'Best upcoming window on $dayName: ${bestUpcomingSlot.temp.toStringAsFixed(1)}°C, ${bestUpcomingSlot.rainProb.round()}% rain risk.';
      }
      bestAltScore = bestUpcomingSlot.score;
    }

    // Find the single BEST activity for the CURRENT LIVE TIME using the exact current hour slot
    final recommendedNow = _findBestActivityForNow(
      targetTime: now,
      weatherData: weatherData,
      aqiData: aqiData,
      currentSlot: selectedSlot.time.hour == now.hour ? selectedSlot : null,
    );

    return ActivityFeasibilityResult(
      activity: activity,
      targetTime: selectedSlot.time,
      score: selectedSlot.score,
      verdict: selectedSlot.verdict,
      verdictTitle: _getVerdictTitle(selectedSlot.verdict),
      summaryExplanation: detailedFeedback.summary,
      positiveFactors: detailedFeedback.positives,
      warningFactors: detailedFeedback.warnings,
      bestAlternativeSlot: bestAltWindow,
      bestAlternativeScore: bestAltScore,
      bestAlternativeReason: bestAltReason,
      bestAlternativeTime: bestUpcomingSlot?.time,
      dayHourlySlots: slots,
      recommendedActivityNow: recommendedNow.activity,
      recommendedScoreNow: recommendedNow.score,
      recommendedReasonNow: recommendedNow.reason,
      recommendedPositivesNow: recommendedNow.positives,
      isAnyActivityFavorableNow: recommendedNow.isFavorable,
    );
  }

  static _ScoreCalcResult _calculateScore({
    required ActivityInfo activity,
    required DateTime slotTime,
    required double temp,
    required double rainProb,
    required double rainMm,
    required int humidity,
    required double visibilityM,
    required double windSpeed,
    required double uv,
    required int aqi,
  }) {
    double score = 100.0;
    bool fatalDealbreaker = false;
    final hour = slotTime.hour;

    // 0. Daylight / Operating Hours Check
    if (activity.requiresDaylight) {
      if (hour < 6 || hour >= 19) {
        score -= 55.0; // Beach swimming, farming spray, and drone photography strictly require daylight
        fatalDealbreaker = true;
      }
    } else if (activity.type == ActivityType.bikeRide || activity.type == ActivityType.running) {
      if (hour < 5 || hour >= 22) {
        // Late night: minor safety deduction (-10 pts) for road caution, NOT a fatal dealbreaker!
        score -= 10.0;
      } else if (hour >= 12 && hour <= 15) {
        // High noon heat / UV penalty for outdoor cardio
        if (temp > 32 || uv > 6) {
          score -= 20.0;
        }
      }
    }
    // Daily commute / driving has NO night penalty (headlights handle dark hours)

    // 1. Rain Penalty (Major for biking, events, photography)
    if (rainProb > activity.maxTolerableRainProb) {
      final excess = rainProb - activity.maxTolerableRainProb;
      score -= (excess * 1.2);
      if (rainProb >= 70 || rainMm > 5.0) {
        fatalDealbreaker = true;
      }
    }

    // 2. Air Quality / AQI Penalty (Major for Running, Cycling)
    if (aqi > activity.maxTolerableAqi) {
      final aqiExcess = aqi - activity.maxTolerableAqi;
      score -= (aqiExcess * 0.25);
      if (aqi >= 350) fatalDealbreaker = true;
    }

    // 3. Visibility Penalty (Crucial for Biking, Commuting, Drone flying)
    if (visibilityM < activity.minTolerableVisibilityMeters) {
      final visRatio = (activity.minTolerableVisibilityMeters - visibilityM) / activity.minTolerableVisibilityMeters;
      score -= (visRatio * 35.0);
      if (visibilityM < 200 && activity.type == ActivityType.bikeRide) {
        fatalDealbreaker = true;
      }
    }

    // 4. Wind Speed Penalty (Crucial for Cycling, Drone, Agri spraying)
    if (windSpeed > activity.maxTolerableWindSpeed) {
      final windExcess = windSpeed - activity.maxTolerableWindSpeed;
      score -= (windExcess * 2.0);
      if (windSpeed > 45.0) fatalDealbreaker = true;
    }

    // 5. Temperature / Heat Range
    if (temp < activity.optimalMinTemp) {
      final diff = activity.optimalMinTemp - temp;
      score -= (diff * 2.5);
    } else if (temp > activity.optimalMaxTemp) {
      final diff = temp - activity.optimalMaxTemp;
      score -= (diff * 3.0);
      if (temp > 42.0) fatalDealbreaker = true;
    }

    // 6. UV Penalty (Running, Beach, Events)
    if (uv > activity.maxTolerableUv) {
      final uvDiff = uv - activity.maxTolerableUv;
      score -= (uvDiff * 4.0);
    }

    int finalScore = score.clamp(0.0, 100.0).round();
    if (fatalDealbreaker && finalScore > 40) {
      finalScore = 38;
    }

    FeasibilityVerdict verdict;
    if (finalScore >= 80) {
      verdict = FeasibilityVerdict.ideal;
    } else if (finalScore >= 60) {
      verdict = FeasibilityVerdict.good;
    } else if (finalScore >= 40) {
      verdict = FeasibilityVerdict.caution;
    } else {
      verdict = FeasibilityVerdict.notRecommended;
    }

    return _ScoreCalcResult(score: finalScore, verdict: verdict);
  }

  static _DetailedReasons _generateDetailedReasons({
    required ActivityInfo activity,
    required HourlyFeasibilitySlot slot,
    required WeatherData weatherData,
    required AqiData aqiData,
  }) {
    final List<String> positives = [];
    final List<String> warnings = [];
    final hour = slot.time.hour;
    final actName = activity.title.split('/').first.trim();

    // 1. Daylight & Timing Checks
    if (activity.requiresDaylight && (hour < 6 || hour >= 19)) {
      if (activity.type == ActivityType.droneFlying) {
        warnings.add('Night hours: Aerial drone photography requires daylight & visual line of sight.');
      } else if (activity.type == ActivityType.beachTrip) {
        warnings.add('After sunset: Beach swimming is unsafe without daylight & lifeguards.');
      } else if (activity.type == ActivityType.farming) {
        warnings.add('Night hours: Crop spraying & farming operations require daylight.');
      } else {
        warnings.add('Daylight required for $actName.');
      }
    } else if ((activity.type == ActivityType.bikeRide || activity.type == ActivityType.running) && (hour < 5 || hour >= 22)) {
      warnings.add('Late night: Use headlights & reflective gear for road safety.');
    } else if (activity.type == ActivityType.commute && (hour < 5 || hour >= 20)) {
      if (slot.visibilityKm >= 5.0 && slot.rainProb <= 20) {
        positives.add('Clear night road conditions (use headlights)');
      }
    } else if (hour >= 6 && hour <= 9) {
      positives.add('Pleasant morning sunlight & cool air');
    } else if (hour >= 16 && hour <= 19) {
      positives.add('Comfortable late afternoon & lower UV');
    }

    // 2. Rain & Precipitation Checks
    if (slot.rainProb > activity.maxTolerableRainProb) {
      if (activity.type == ActivityType.bikeRide) {
        warnings.add('Rain (${slot.rainProb.round()}%): Slippery road and skidding hazard.');
      } else if (activity.type == ActivityType.running) {
        warnings.add('Rain (${slot.rainProb.round()}%): Wet surfaces & reduced grip.');
      } else if (activity.type == ActivityType.farming) {
        warnings.add('Rain (${slot.rainProb.round()}%): Spray will wash off crops.');
      } else if (activity.type == ActivityType.droneFlying) {
        warnings.add('Rain (${slot.rainProb.round()}%): Water moisture risks drone electronics.');
      } else if (activity.type == ActivityType.beachTrip) {
        warnings.add('Rain & overcast: Unsafe waters and no sunshine.');
      } else {
        warnings.add('Rain chance (${slot.rainProb.round()}%): Wet outdoor conditions.');
      }
    } else if (slot.rainProb <= 15) {
      positives.add('Dry weather (${slot.rainProb.round()}% rain risk)');
    }

    // 3. Air Quality Checks
    if (slot.aqi > activity.maxTolerableAqi) {
      warnings.add('Poor air quality (AQI ${slot.aqi}): Strains breathing.');
    } else if (slot.aqi <= 60 && (activity.type == ActivityType.running || activity.type == ActivityType.bikeRide)) {
      positives.add('Clean air (AQI ${slot.aqi}) for easy breathing');
    }

    // 4. Wind Checks
    if (slot.windSpeed > activity.maxTolerableWindSpeed) {
      if (activity.type == ActivityType.droneFlying) {
        warnings.add('High wind (${slot.windSpeed.toStringAsFixed(1)} km/h): Exceeds drone flight limits.');
      } else if (activity.type == ActivityType.farming) {
        warnings.add('High wind (${slot.windSpeed.toStringAsFixed(1)} km/h): Causes spray drift.');
      } else {
        warnings.add('Strong wind gusts (${slot.windSpeed.toStringAsFixed(1)} km/h).');
      }
    } else if (slot.windSpeed <= 15) {
      positives.add('Gentle breeze (${slot.windSpeed.toStringAsFixed(1)} km/h)');
    }

    // 5. Visibility Checks
    if (slot.visibilityKm < (activity.minTolerableVisibilityMeters / 1000.0)) {
      warnings.add('Low visibility (${(slot.visibilityKm * 1000).round()}m) due to mist/fog.');
    } else if (slot.visibilityKm >= 5.0) {
      positives.add('Clear road visibility (${slot.visibilityKm.toStringAsFixed(1)} km)');
    }

    // 6. Temperature Checks
    if (slot.temp > activity.optimalMaxTemp + 3) {
      warnings.add('Elevated heat (${slot.temp.toStringAsFixed(1)}°C): Risk of dehydration.');
    } else if (slot.temp < activity.optimalMinTemp - 4) {
      warnings.add('Chilly temperature (${slot.temp.toStringAsFixed(1)}°C).');
    } else if (slot.temp >= activity.optimalMinTemp && slot.temp <= activity.optimalMaxTemp) {
      positives.add('Pleasant temperature (${slot.temp.toStringAsFixed(1)}°C)');
    }

    String summary;
    if (slot.verdict == FeasibilityVerdict.ideal) {
      summary = 'Great time for $actName! Optimal conditions.';
    } else if (slot.verdict == FeasibilityVerdict.good) {
      summary = 'Good weather for $actName with minor conditions.';
    } else if (slot.verdict == FeasibilityVerdict.caution) {
      summary = 'Weather is not ideal for $actName right now.';
    } else {
      summary = 'Unfavorable weather for $actName at this time.';
    }

    return _DetailedReasons(
      summary: summary,
      positives: positives.take(3).toList(),
      warnings: warnings.take(3).toList(),
    );
  }

  static _RecommendedNowResult _findBestActivityForNow({
    required DateTime targetTime,
    required WeatherData weatherData,
    required AqiData aqiData,
    HourlyFeasibilitySlot? currentSlot,
  }) {
    final nowHour = targetTime.hour;
    HourlyWeather? matchHour;
    for (final h in weatherData.hourlyForecast) {
      if (h.time.hour == nowHour && h.time.day == targetTime.day) {
        matchHour = h;
        break;
      }
    }

    final temp = currentSlot?.temp ?? matchHour?.temperature ?? weatherData.currentTemp;
    final rainProb = currentSlot?.rainProb ?? matchHour?.precipitationProbability ?? weatherData.precipitationProbability;
    final rainMm = matchHour?.precipitation ?? (weatherData.precipitation > 0 ? weatherData.precipitation : 0.0);
    final humidity = matchHour?.humidity ?? weatherData.relativeHumidity;
    final visibilityM = (currentSlot != null ? currentSlot.visibilityKm * 1000 : null) ?? matchHour?.visibilityMeters ?? weatherData.visibilityMeters;
    final windSpeed = currentSlot?.windSpeed ?? matchHour?.windSpeed ?? weatherData.windSpeed;
    final uv = matchHour?.uvIndex ?? weatherData.uvIndex;
    final aqi = currentSlot?.aqi ?? aqiData.aqi;

    ActivityInfo? bestActivity;
    int highestScore = -1;
    String bestReason = '';

    for (final act in ActivityInfo.supportedActivities) {
      final res = _calculateScore(
        activity: act,
        slotTime: targetTime,
        temp: temp,
        rainProb: rainProb,
        rainMm: rainMm,
        humidity: humidity,
        visibilityM: visibilityM,
        windSpeed: windSpeed,
        uv: uv,
        aqi: aqi,
      );

      if (res.score > highestScore) {
        highestScore = res.score;
        bestActivity = act;

        if (act.type == ActivityType.commute) {
          bestReason = 'Optimal road visibility (${(visibilityM / 1000).toStringAsFixed(1)} km) & smooth commute conditions.';
        } else if (act.type == ActivityType.bikeRide) {
          bestReason = 'Dry road surfaces (${rainProb.round()}% rain) & gentle breeze (${windSpeed.toStringAsFixed(1)} km/h).';
        } else if (act.type == ActivityType.running) {
          bestReason = 'Good atmospheric conditions & acceptable AQI ($aqi) for outdoor cardio.';
        } else if (act.type == ActivityType.farming) {
          bestReason = 'Stable wind conditions (${windSpeed.toStringAsFixed(1)} km/h) suitable for field operations.';
        } else if (act.type == ActivityType.droneFlying) {
          bestReason = 'High optical visibility & safe wind speed for aerial flights.';
        } else if (act.type == ActivityType.outdoorEvent) {
          bestReason = 'Comfortable ambient weather with low rain probability.';
        } else {
          bestReason = 'Favorable weather conditions at present.';
        }
      }
    }

    final isRaining = rainProb >= 40.0 || rainMm > 0.1 || weatherData.weatherCode >= 51;
    final isFavorable = highestScore >= 60 && !isRaining;

    final List<String> currentPositives = [];
    if (isFavorable) {
      if (rainProb < 20) {
        currentPositives.add('Low chance of rain (${rainProb.round()}%) - Dry conditions');
      }
      if (visibilityM >= 3000) {
        currentPositives.add('Clear visibility (${(visibilityM / 1000).toStringAsFixed(1)} km)');
      }
      if (aqi <= 100) {
        currentPositives.add('Good air quality (AQI $aqi)');
      }
      if (temp >= 18 && temp <= 32) {
        currentPositives.add('Pleasant ambient temperature (${temp.toStringAsFixed(1)}°C)');
      }
      if (windSpeed <= 20) {
        currentPositives.add('Gentle breeze (${windSpeed.toStringAsFixed(1)} km/h)');
      }
    } else {
      bestActivity = null;
      bestReason = isRaining
          ? 'Active precipitation (${rainProb.round()}% rain) and wet surface hazards. Outdoor activities not advised right now.'
          : 'Current weather conditions are unfavorable for outdoor activities right now.';
    }

    return _RecommendedNowResult(
      activity: bestActivity,
      score: highestScore,
      reason: bestReason,
      positives: currentPositives,
      isFavorable: isFavorable,
    );
  }

  static String _getVerdictTitle(FeasibilityVerdict verdict) {
    switch (verdict) {
      case FeasibilityVerdict.ideal:
        return 'Ideal Conditions (Highly Recommended)';
      case FeasibilityVerdict.good:
        return 'Good Conditions (Recommended)';
      case FeasibilityVerdict.caution:
        return 'Caution Advised (Moderate Risk)';
      case FeasibilityVerdict.notRecommended:
        return 'Not Recommended (Hazardous / Poor)';
    }
  }
}

class _ScoreCalcResult {
  final int score;
  final FeasibilityVerdict verdict;

  _ScoreCalcResult({required this.score, required this.verdict});
}

class _DetailedReasons {
  final String summary;
  final List<String> positives;
  final List<String> warnings;

  _DetailedReasons({
    required this.summary,
    required this.positives,
    required this.warnings,
  });
}

class _RecommendedNowResult {
  final ActivityInfo? activity;
  final int score;
  final String reason;
  final List<String> positives;
  final bool isFavorable;

  _RecommendedNowResult({
    required this.activity,
    required this.score,
    required this.reason,
    required this.positives,
    required this.isFavorable,
  });
}
