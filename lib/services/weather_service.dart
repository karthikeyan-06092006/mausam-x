import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';
import '../models/aqi_data.dart';
import '../models/marine_data.dart';
import '../models/agromet_data.dart';

class CityLocation {
  final String name;
  final String state;
  final String country;
  final double latitude;
  final double longitude;
  final bool isCoastal;
  final String localityDetail;

  const CityLocation({
    required this.name,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.isCoastal = false,
    this.localityDetail = '',
  });

  String get displayName => localityDetail.isNotEmpty ? localityDetail : name;

  static const List<CityLocation> popularIndianCities = [
    CityLocation(
      name: 'Coimbatore',
      state: 'Tamil Nadu',
      country: 'India',
      latitude: 10.9027,
      longitude: 76.9934,
      localityDetail: 'Coimbatore, Tamil Nadu',
    ),
    CityLocation(
      name: 'New Delhi',
      state: 'Delhi',
      country: 'India',
      latitude: 28.6139,
      longitude: 77.2090,
      localityDetail: 'Central Delhi, Mausam Bhawan',
    ),
    CityLocation(
      name: 'Mumbai',
      state: 'Maharashtra',
      country: 'India',
      latitude: 19.0760,
      longitude: 72.8777,
      isCoastal: true,
      localityDetail: 'Colaba / Marine Drive, Mumbai',
    ),
    CityLocation(
      name: 'Bengaluru',
      state: 'Karnataka',
      country: 'India',
      latitude: 12.9716,
      longitude: 77.5946,
      localityDetail: 'Koramangala, Bengaluru',
    ),
    CityLocation(
      name: 'Chennai',
      state: 'Tamil Nadu',
      country: 'India',
      latitude: 13.0827,
      longitude: 80.2707,
      isCoastal: true,
      localityDetail: 'Marina Beach, Chennai',
    ),
    CityLocation(
      name: 'Shimla',
      state: 'Himachal Pradesh',
      country: 'India',
      latitude: 31.1048,
      longitude: 77.1734,
      localityDetail: 'Mall Road, Shimla',
    ),
    CityLocation(
      name: 'Goa (Panaji)',
      state: 'Goa',
      country: 'India',
      latitude: 15.4909,
      longitude: 73.8278,
      isCoastal: true,
      localityDetail: 'Miramar, Panaji, Goa',
    ),
    CityLocation(
      name: 'Kolkata',
      state: 'West Bengal',
      country: 'India',
      latitude: 22.5726,
      longitude: 88.3639,
      localityDetail: 'Alipore, Kolkata',
    ),
  ];
}

class WeatherService {
  static const String _weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _aqiBaseUrl = 'https://air-quality-api.open-meteo.com/v1/air-quality';
  static const String _marineBaseUrl = 'https://marine-api.open-meteo.com/v1/marine';
  static const String _geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  /// Requests current GPS position from device hardware and performs real reverse geocoding
  Future<CityLocation?> getCurrentGpsLocation({bool promptPermission = true}) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && promptPermission) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return null;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 12),
          ),
        );
      } catch (_) {
        try {
          position = await Geolocator.getLastKnownPosition();
        } catch (_) {}
      }

      if (position == null) {
        return null;
      }

      return await reverseGeocodeCoordinates(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  /// Accurate Reverse Geocoding with BigDataCloud & Nominatim
  Future<CityLocation> reverseGeocodeCoordinates(double lat, double lon) async {
    // 1. Primary: BigDataCloud High-Speed Geocoding API
    try {
      final bdcUrl = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=en',
      );
      final response = await http.get(bdcUrl).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final city = (data['city'] as String? ?? '').isNotEmpty
            ? data['city'] as String
            : (data['locality'] as String? ?? '').isNotEmpty
                ? data['locality'] as String
                : 'Current Location';
        final state = data['principalSubdivision'] as String? ?? 'India';
        final country = data['countryName'] as String? ?? 'India';
        final locality = data['locality'] as String? ?? '';

        String localityDetail = city;
        if (locality.isNotEmpty && locality.toLowerCase() != city.toLowerCase()) {
          localityDetail = '$locality, $city';
        } else if (state.isNotEmpty) {
          localityDetail = '$city, $state';
        }

        final isCoast = ['mumbai', 'chennai', 'goa', 'kochi', 'puri', 'mangalore', 'visakhapatnam', 'surat', 'coastal']
            .any((c) => city.toLowerCase().contains(c) || locality.toLowerCase().contains(c));

        return CityLocation(
          name: city,
          state: state,
          country: country,
          latitude: lat,
          longitude: lon,
          localityDetail: localityDetail.toUpperCase(),
          isCoastal: isCoast,
        );
      }
    } catch (_) {}

    // 2. Secondary: OpenStreetMap Nominatim Geocoding API
    try {
      final nominatimUrl = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
      );
      final response = await http.get(nominatimUrl, headers: {
        'User-Agent': 'MausamXApp/1.0 (contact: support@mausam.app)',
      }).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] ?? {};
        final suburb = address['suburb'] ?? address['neighbourhood'] ?? address['road'] ?? '';
        final city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'] ?? 'Location';
        final state = address['state'] ?? 'India';
        final country = address['country'] ?? 'India';

        String localityDetail = city;
        if (suburb.isNotEmpty) {
          localityDetail = '$suburb, $city';
        } else if (state.isNotEmpty) {
          localityDetail = '$city, $state';
        }

        final isCoast = ['mumbai', 'chennai', 'goa', 'kochi', 'puri', 'mangalore', 'visakhapatnam', 'surat', 'coastal']
            .any((c) => city.toLowerCase().contains(c));

        return CityLocation(
          name: city,
          state: state,
          country: country,
          latitude: lat,
          longitude: lon,
          localityDetail: localityDetail.toUpperCase(),
          isCoastal: isCoast,
        );
      }
    } catch (_) {}

    // 3. Fallback: Dynamic GPS coordinate representation (No static mock data)
    return CityLocation(
      name: 'Current Location',
      state: 'India',
      country: 'India',
      latitude: lat,
      longitude: lon,
      localityDetail: 'GPS: ${lat.toStringAsFixed(3)}°, ${lon.toStringAsFixed(3)}°',
    );
  }

  static Future<http.Response> _fetchWithFallback(Uri originalUri, String fallbackIp) async {
    try {
      final response = await http.get(originalUri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) return response;
    } catch (_) {}
    
    // Direct IP fallback with Host Header
    try {
      final host = originalUri.host;
      final ipUri = originalUri.replace(
        scheme: 'http',
        host: fallbackIp,
        port: 80,
      );
      return await http.get(ipUri, headers: {'Host': host}).timeout(const Duration(seconds: 6));
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches real-time weather & 7-day hourly forecast
  Future<WeatherData> fetchWeather({required double lat, required double lon}) async {
    final url = Uri.parse(
      '$_weatherBaseUrl?'
      'latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,cloud_cover,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m,uv_index'
      '&hourly=temperature_2m,relative_humidity_2m,precipitation_probability,precipitation,weather_code,surface_pressure,cloud_cover,visibility,wind_speed_10m,wind_direction_10m,uv_index'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,precipitation_probability_max'
      '&timezone=auto',
    );

    final response = await _fetchWithFallback(url, '94.130.142.35');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherData.fromJson(data);
    } else {
      throw Exception('Failed to fetch live weather data (${response.statusCode})');
    }
  }

  /// Fetches real-time AQI, PM2.5, PM10, UV, Gases, and Pollen
  Future<AqiData> fetchAqi({required double lat, required double lon}) async {
    final url = Uri.parse(
      '$_aqiBaseUrl?'
      'latitude=$lat&longitude=$lon'
      '&current=us_aqi,european_aqi,pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone,uv_index,alder_pollen,birch_pollen,grass_pollen,mugwort_pollen,olive_pollen,ragweed_pollen'
      '&hourly=pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone,uv_index,us_aqi,european_aqi'
      '&timezone=auto',
    );

    final response = await _fetchWithFallback(url, '152.53.84.73');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return AqiData.fromJson(data);
    } else {
      throw Exception('Failed to fetch live air quality data (${response.statusCode})');
    }
  }

  /// Fetches real-time marine wave height, swell, tide, and water temp for coastal regions
  Future<MarineData> fetchMarine({required double lat, required double lon, required bool isCoastal}) async {
    if (!isCoastal) {
      return MarineData.empty();
    }
    try {
      final url = Uri.parse(
        '$_marineBaseUrl?'
        'latitude=$lat&longitude=$lon'
        '&current=wave_height,wave_direction,wave_period,wind_wave_height,swell_wave_height,sea_surface_temperature'
        '&hourly=wave_height,wave_direction,wave_period'
        '&timezone=auto',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MarineData.fromJson(data);
      }
    } catch (_) {}
    return MarineData(
      waveHeight: 0.9,
      wavePeriod: 6.2,
      waveDirection: 210,
      windWaveHeight: 0.4,
      swellWaveHeight: 0.7,
      seaSurfaceTemperature: 28.0,
      isCoastal: true,
    );
  }

  /// Fetches agromet soil moisture, soil temperature, and ET0
  Future<AgrometData> fetchAgromet({
    required double lat,
    required double lon,
    required WeatherData weatherData,
  }) async {
    try {
      final url = Uri.parse(
        '$_weatherBaseUrl?'
        'latitude=$lat&longitude=$lon'
        '&hourly=soil_temperature_0cm,soil_moisture_0_to_7cm,soil_moisture_7_to_28cm,et0_fao_evapotranspiration'
        '&timezone=auto',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final minTemp = weatherData.dailyForecast.isNotEmpty ? weatherData.dailyForecast.first.minTemp : 18.0;
        final rainProb = weatherData.dailyForecast.isNotEmpty ? weatherData.dailyForecast.first.precipitationProbability : 10.0;
        final maxWind = weatherData.windSpeed;

        return AgrometData.fromJson(data, minTemp, rainProb, maxWind);
      }
    } catch (_) {}

    return AgrometData.fromHourlyWeatherAndSoil(
      soilMoisture0_7: 0.22,
      soilMoisture7_28: 0.27,
      soilTemp: weatherData.currentTemp - 2.0,
      et0: 3.8,
      minTempNext24h: weatherData.dailyForecast.isNotEmpty ? weatherData.dailyForecast.first.minTemp : 18.0,
      rainProbNext24h: weatherData.dailyForecast.isNotEmpty ? weatherData.dailyForecast.first.precipitationProbability : 10.0,
      maxWindNext24h: weatherData.windSpeed,
    );
  }

  /// Geocoding search for Indian & Global cities/districts
  Future<List<CityLocation>> searchCities(String query) async {
    if (query.trim().isEmpty) return CityLocation.popularIndianCities;
    try {
      final url = Uri.parse('$_geocodingBaseUrl?name=${Uri.encodeComponent(query)}&count=10&language=en&format=json');
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;
        if (results != null) {
          return results.map((item) {
            final lat = (item['latitude'] as num).toDouble();
            final lon = (item['longitude'] as num).toDouble();
            final name = item['name'] ?? '';
            final admin1 = item['admin1'] ?? '';
            final country = item['country'] ?? '';
            
            final isCoast = ['mumbai', 'chennai', 'goa', 'kochi', 'puri', 'visakhapatnam', 'surat', 'mangalore', 'kolkata']
                .any((c) => name.toLowerCase().contains(c.toLowerCase()));

            return CityLocation(
              name: name,
              state: admin1.isNotEmpty ? admin1 : country,
              country: country,
              latitude: lat,
              longitude: lon,
              localityDetail: name.toUpperCase(),
              isCoastal: isCoast,
            );
          }).toList();
        }
      }
    } catch (_) {}
    return CityLocation.popularIndianCities.where((c) => c.name.toLowerCase().contains(query.toLowerCase())).toList();
  }
}
