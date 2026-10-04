import 'dart:convert';
import 'package:http/http.dart' as http;

class RadarFrame {
  final int timestamp;
  final String path;

  RadarFrame({required this.timestamp, required this.path});
}

class RadarTileService {
  static const String _rainViewerMapsApi = 'https://api.rainviewer.com/public/weather-maps.json';

  /// Fetches real-time available radar and satellite frames from RainViewer API
  static Future<Map<String, dynamic>> fetchLiveRadarMetadata() async {
    try {
      http.Response? response;
      try {
        response = await http.get(Uri.parse(_rainViewerMapsApi)).timeout(const Duration(seconds: 4));
      } catch (_) {
        response = await http.get(
          Uri.parse('http://176.9.90.248/public/weather-maps.json'),
          headers: {'Host': 'api.rainviewer.com'},
        ).timeout(const Duration(seconds: 5));
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final host = data['host'] as String? ?? 'https://tilecache.rainviewer.com';
        
        final radarObj = data['radar'] ?? {};
        final pastList = (radarObj['past'] as List<dynamic>?) ?? [];
        final nowcastList = (radarObj['nowcast'] as List<dynamic>?) ?? [];

        final List<RadarFrame> pastFrames = pastList.map((item) {
          return RadarFrame(
            timestamp: item['time'] as int,
            path: item['path'] as String,
          );
        }).toList();

        final List<RadarFrame> nowcastFrames = nowcastList.map((item) {
          return RadarFrame(
            timestamp: item['time'] as int,
            path: item['path'] as String,
          );
        }).toList();

        final satelliteObj = data['satellite'] ?? {};
        final satInfrared = (satelliteObj['infrared'] as List<dynamic>?) ?? [];
        final List<RadarFrame> satFrames = satInfrared.map((item) {
          return RadarFrame(
            timestamp: item['time'] as int,
            path: item['path'] as String,
          );
        }).toList();

        return {
          'host': host,
          'pastRadar': pastFrames,
          'nowcastRadar': nowcastFrames,
          'satelliteFrames': satFrames,
        };
      }
    } catch (_) {}

    return {
      'host': 'https://tilecache.rainviewer.com',
      'pastRadar': <RadarFrame>[],
      'nowcastRadar': <RadarFrame>[],
      'satelliteFrames': <RadarFrame>[],
    };
  }
}
