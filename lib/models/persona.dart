enum PersonaType {
  general,
  health,
  fitness,
  beach,
  traveler,
  family,
  agriculture,
  commuter,
  eventPlanner,
}

class PersonaInfo {
  final PersonaType type;
  final String title;
  final String subtitle;
  final String iconName;
  final String badgeText;

  const PersonaInfo({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.badgeText,
  });

  static const List<PersonaInfo> allPersonas = [
    PersonaInfo(
      type: PersonaType.general,
      title: 'Universal Mausam',
      subtitle: 'Comprehensive national meteorological view',
      iconName: 'sparkles',
      badgeText: 'All Overview',
    ),
    PersonaInfo(
      type: PersonaType.health,
      title: 'Health-Conscious',
      subtitle: 'AQI, Pollen breakdown, UV index, respiratory health alerts',
      iconName: 'heart_pulse',
      badgeText: 'Air & Health',
    ),
    PersonaInfo(
      type: PersonaType.fitness,
      title: 'Outdoor Fitness',
      subtitle: 'Best running hours, sunrise/sunset, wind speed, heat alerts',
      iconName: 'run',
      badgeText: 'Fitness & Runs',
    ),
    PersonaInfo(
      type: PersonaType.beach,
      title: 'Beachgoers & Surfers',
      subtitle: 'Sea conditions, tide timings, wave height, water temp',
      iconName: 'waves',
      badgeText: 'Marine & Waves',
    ),
    PersonaInfo(
      type: PersonaType.traveler,
      title: 'Travelers',
      subtitle: 'Multi-destination forecasts, flight severe alerts, packing guide',
      iconName: 'airplane',
      badgeText: 'Travel & Packing',
    ),
    PersonaInfo(
      type: PersonaType.family,
      title: 'Parents & Families',
      subtitle: 'School commute windows, rain alerts, severe weather warnings',
      iconName: 'family_restroom',
      badgeText: 'School & Family',
    ),
    PersonaInfo(
      type: PersonaType.agriculture,
      title: 'Agriculture & Gardeners',
      subtitle: 'Soil moisture, rainfall forecast, frost alerts, agromet advice',
      iconName: 'eco',
      badgeText: 'Agri & Soil',
    ),
    PersonaInfo(
      type: PersonaType.commuter,
      title: 'Commuters',
      subtitle: 'Road visibility, fog meters, storm alerts, traffic weather risk',
      iconName: 'directions_car',
      badgeText: 'Road & Fog',
    ),
    PersonaInfo(
      type: PersonaType.eventPlanner,
      title: 'Event Planners',
      subtitle: 'Extended rain probability, outdoor comfort index (Humidex)',
      iconName: 'event',
      badgeText: 'Events & Comfort',
    ),
  ];
}
