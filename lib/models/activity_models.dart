enum ActivityType {
  bikeRide,
  running,
  beachTrip,
  commute,
  farming,
  outdoorEvent,
  droneFlying,
  walking,
}

class ActivityInfo {
  final ActivityType type;
  final String title;
  final String description;
  final String iconKey;
  final double optimalMinTemp;
  final double optimalMaxTemp;
  final double maxTolerableRainProb;
  final double maxTolerableWindSpeed;
  final int maxTolerableAqi;
  final double minTolerableVisibilityMeters;
  final double maxTolerableUv;
  final bool requiresDaylight;
  final int activeStartHour; // e.g. 5 = 5:00 AM
  final int activeEndHour;   // e.g. 20 = 8:00 PM

  const ActivityInfo({
    required this.type,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.optimalMinTemp,
    required this.optimalMaxTemp,
    required this.maxTolerableRainProb,
    required this.maxTolerableWindSpeed,
    required this.maxTolerableAqi,
    required this.minTolerableVisibilityMeters,
    required this.maxTolerableUv,
    this.requiresDaylight = false,
    this.activeStartHour = 5,
    this.activeEndHour = 22,
  });

  static const List<ActivityInfo> supportedActivities = [
    ActivityInfo(
      type: ActivityType.bikeRide,
      title: 'Bike Ride / Cycling',
      description: 'Calculates road traction, visibility, wind gusts, and air quality.',
      iconKey: 'two_wheeler',
      optimalMinTemp: 16.0,
      optimalMaxTemp: 30.0,
      maxTolerableRainProb: 30.0,
      maxTolerableWindSpeed: 25.0,
      maxTolerableAqi: 180,
      minTolerableVisibilityMeters: 1000.0,
      maxTolerableUv: 7.0,
      requiresDaylight: false,
      activeStartHour: 5,
      activeEndHour: 20,
    ),
    ActivityInfo(
      type: ActivityType.running,
      title: 'Outdoor Running / Workout',
      description: 'Prioritizes clean air (AQI), low UV index, and comfortable heat index.',
      iconKey: 'directions_run',
      optimalMinTemp: 14.0,
      optimalMaxTemp: 26.0,
      maxTolerableRainProb: 35.0,
      maxTolerableWindSpeed: 20.0,
      maxTolerableAqi: 150,
      minTolerableVisibilityMeters: 800.0,
      maxTolerableUv: 5.0,
      requiresDaylight: false,
      activeStartHour: 5,
      activeEndHour: 20,
    ),
    ActivityInfo(
      type: ActivityType.beachTrip,
      title: 'Beach & Swimming',
      description: 'Checks wave heights, sea temperature, sunshine, and wind speed.',
      iconKey: 'beach_access',
      optimalMinTemp: 22.0,
      optimalMaxTemp: 34.0,
      maxTolerableRainProb: 20.0,
      maxTolerableWindSpeed: 28.0,
      maxTolerableAqi: 220,
      minTolerableVisibilityMeters: 2000.0,
      maxTolerableUv: 9.0,
      requiresDaylight: true,
      activeStartHour: 6,
      activeEndHour: 18,
    ),
    ActivityInfo(
      type: ActivityType.commute,
      title: 'Daily Commute & Driving',
      description: 'Monitors fog/visibility meters, rain storm risks, and waterlogging.',
      iconKey: 'commute',
      optimalMinTemp: 5.0,
      optimalMaxTemp: 42.0,
      maxTolerableRainProb: 65.0,
      maxTolerableWindSpeed: 45.0,
      maxTolerableAqi: 350,
      minTolerableVisibilityMeters: 500.0,
      maxTolerableUv: 12.0,
      requiresDaylight: false,
      activeStartHour: 0,
      activeEndHour: 23,
    ),
    ActivityInfo(
      type: ActivityType.farming,
      title: 'Farming / Spraying / Sowing',
      description: 'Checks wind drift, soil moisture, rainfall within 24h, and frost risk.',
      iconKey: 'agriculture',
      optimalMinTemp: 15.0,
      optimalMaxTemp: 32.0,
      maxTolerableRainProb: 25.0,
      maxTolerableWindSpeed: 16.0,
      maxTolerableAqi: 280,
      minTolerableVisibilityMeters: 1000.0,
      maxTolerableUv: 10.0,
      requiresDaylight: true,
      activeStartHour: 6,
      activeEndHour: 18,
    ),
    ActivityInfo(
      type: ActivityType.outdoorEvent,
      title: 'Outdoor Event / Gathering',
      description: 'Evaluates rain probability, comfort index, and temperature range.',
      iconKey: 'celebration',
      optimalMinTemp: 16.0,
      optimalMaxTemp: 32.0,
      maxTolerableRainProb: 20.0,
      maxTolerableWindSpeed: 22.0,
      maxTolerableAqi: 180,
      minTolerableVisibilityMeters: 1500.0,
      maxTolerableUv: 7.0,
      requiresDaylight: false,
      activeStartHour: 8,
      activeEndHour: 23,
    ),
    ActivityInfo(
      type: ActivityType.droneFlying,
      title: 'Drone Flying / Photography',
      description: 'Crucial wind speed, gust safety, cloud cover, and visibility.',
      iconKey: 'videocam',
      optimalMinTemp: 10.0,
      optimalMaxTemp: 35.0,
      maxTolerableRainProb: 10.0,
      maxTolerableWindSpeed: 18.0,
      maxTolerableAqi: 300,
      minTolerableVisibilityMeters: 3000.0,
      maxTolerableUv: 10.0,
      requiresDaylight: true,
      activeStartHour: 6,
      activeEndHour: 18,
    ),
  ];

  static ActivityInfo getByType(ActivityType type) {
    return supportedActivities.firstWhere(
      (a) => a.type == type,
      orElse: () => supportedActivities.first,
    );
  }
}

enum FeasibilityVerdict {
  ideal,
  good,
  caution,
  notRecommended,
}

class ActivityFeasibilityResult {
  final ActivityInfo activity;
  final DateTime targetTime;
  final int score; // 0 to 100
  final FeasibilityVerdict verdict;
  final String verdictTitle;
  final String summaryExplanation;
  final List<String> positiveFactors;
  final List<String> warningFactors;
  
  // Real-time recommendation across ALL activities for current live conditions
  final ActivityInfo? recommendedActivityNow;
  final int recommendedScoreNow;
  final String recommendedReasonNow;
  final List<String> recommendedPositivesNow;
  final bool isAnyActivityFavorableNow;

  // Best time for the currently selected activity
  final String? bestAlternativeSlot;
  final int bestAlternativeScore;
  final String? bestAlternativeReason;
  final DateTime? bestAlternativeTime;

  final List<HourlyFeasibilitySlot> dayHourlySlots;

  ActivityFeasibilityResult({
    required this.activity,
    required this.targetTime,
    required this.score,
    required this.verdict,
    required this.verdictTitle,
    required this.summaryExplanation,
    required this.positiveFactors,
    required this.warningFactors,
    this.bestAlternativeSlot,
    this.bestAlternativeScore = 0,
    this.bestAlternativeReason,
    this.bestAlternativeTime,
    required this.dayHourlySlots,
    this.recommendedActivityNow,
    required this.recommendedScoreNow,
    required this.recommendedReasonNow,
    required this.recommendedPositivesNow,
    this.isAnyActivityFavorableNow = true,
  });
}

class HourlyFeasibilitySlot {
  final DateTime time;
  final int score;
  final FeasibilityVerdict verdict;
  final double temp;
  final double rainProb;
  final int aqi;
  final double visibilityKm;
  final double windSpeed;

  HourlyFeasibilitySlot({
    required this.time,
    required this.score,
    required this.verdict,
    required this.temp,
    required this.rainProb,
    required this.aqi,
    required this.visibilityKm,
    required this.windSpeed,
  });
}
