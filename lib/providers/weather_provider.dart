import 'package:flutter/foundation.dart';
import '../models/weather_data.dart';
import '../models/aqi_data.dart';
import '../models/marine_data.dart';
import '../models/agromet_data.dart';
import '../models/persona.dart';
import '../models/activity_models.dart';
import '../services/weather_service.dart';
import '../services/activity_scoring_engine.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();

  CityLocation _selectedCity = CityLocation.popularIndianCities[0]; // Default to Coimbatore / Boys Hostel Karpagam College Road
  PersonaType _selectedPersona = PersonaType.general;
  ActivityType _selectedActivity = ActivityType.bikeRide;
  DateTime _selectedActivityTime = DateTime.now();

  WeatherData? _weatherData;
  AqiData? _aqiData;
  MarineData? _marineData;
  AgrometData? _agrometData;
  ActivityFeasibilityResult? _feasibilityResult;

  bool _isLoading = true;
  bool _isLocating = false;
  bool _isActivityCardExpanded = false;
  String? _errorMessage;

  // Getters
  CityLocation get selectedCity => _selectedCity;
  PersonaType get selectedPersona => _selectedPersona;
  ActivityType get selectedActivity => _selectedActivity;
  DateTime get selectedActivityTime => _selectedActivityTime;
  WeatherData? get weatherData => _weatherData;
  AqiData? get aqiData => _aqiData;
  MarineData? get marineData => _marineData;
  AgrometData? get agrometData => _agrometData;
  ActivityFeasibilityResult? get feasibilityResult => _feasibilityResult;
  bool get isLoading => _isLoading;
  bool get isLocating => _isLocating;
  bool get isActivityCardExpanded => _isActivityCardExpanded;
  String? get errorMessage => _errorMessage;

  void toggleActivityCardExpanded() {
    _isActivityCardExpanded = !_isActivityCardExpanded;
    notifyListeners();
  }

  void setActivityCardExpanded(bool expanded) {
    _isActivityCardExpanded = expanded;
    notifyListeners();
  }

  WeatherProvider() {
    initApp();
  }

  Future<void> initApp() async {
    final success = await fetchCurrentGpsLocation(promptPermission: false);
    if (!success && _weatherData == null) {
      await loadWeatherData();
    }
  }

  Future<bool> fetchCurrentGpsLocation({bool promptPermission = true}) async {
    _isLocating = true;
    notifyListeners();
    try {
      final loc = await _service.getCurrentGpsLocation(promptPermission: promptPermission);
      if (loc != null) {
        _selectedCity = loc;
        _errorMessage = null;
        await loadWeatherData();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  Future<void> setCity(CityLocation city) async {
    _selectedCity = city;
    notifyListeners();
    await loadWeatherData();
  }

  void setPersona(PersonaType persona) {
    _selectedPersona = persona;
    switch (persona) {
      case PersonaType.fitness:
        _selectedActivity = ActivityType.running;
        break;
      case PersonaType.beach:
        _selectedActivity = ActivityType.beachTrip;
        break;
      case PersonaType.agriculture:
        _selectedActivity = ActivityType.farming;
        break;
      case PersonaType.commuter:
        _selectedActivity = ActivityType.commute;
        break;
      case PersonaType.eventPlanner:
        _selectedActivity = ActivityType.outdoorEvent;
        break;
      default:
        break;
    }
    _recalculateFeasibility();
    notifyListeners();
  }

  void setActivity(ActivityType activity) {
    _selectedActivity = activity;
    _recalculateFeasibility();
    notifyListeners();
  }

  void setActivityTime(DateTime time) {
    _selectedActivityTime = time;
    _recalculateFeasibility();
    notifyListeners();
  }

  Future<void> loadWeatherData() async {
    _isLoading = _weatherData == null;
    _errorMessage = null;
    notifyListeners();

    try {
      final lat = _selectedCity.latitude;
      final lon = _selectedCity.longitude;

      final weatherFuture = _service.fetchWeather(lat: lat, lon: lon);
      final aqiFuture = _service.fetchAqi(lat: lat, lon: lon);
      final marineFuture = _service.fetchMarine(lat: lat, lon: lon, isCoastal: _selectedCity.isCoastal);

      final results = await Future.wait([weatherFuture, aqiFuture, marineFuture]);

      _weatherData = results[0] as WeatherData;
      _aqiData = results[1] as AqiData;
      _marineData = results[2] as MarineData;

      _agrometData = await _service.fetchAgromet(lat: lat, lon: lon, weatherData: _weatherData!);

      _recalculateFeasibility();
    } catch (e) {
      if (_weatherData == null) {
        _errorMessage = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _recalculateFeasibility() {
    if (_weatherData == null || _aqiData == null) return;
    final activityInfo = ActivityInfo.getByType(_selectedActivity);
    _feasibilityResult = ActivityScoringEngine.evaluateActivity(
      activity: activityInfo,
      targetTime: _selectedActivityTime,
      weatherData: _weatherData!,
      aqiData: _aqiData!,
    );
  }

  Future<List<CityLocation>> searchCities(String query) async {
    return _service.searchCities(query);
  }
}
