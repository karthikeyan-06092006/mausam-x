import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/imd_station_models.dart';
import '../providers/weather_provider.dart';
import '../services/radar_tile_service.dart';
import '../services/weather_service.dart';

enum MapBaseStyle {
  darkCarto,
  satellite,
  osmLight,
}

enum WeatherOverlayLayer {
  dopplerRadar,
  satelliteClouds,
  temperatureHeat,
  aqiOverlay,
  none,
}

class ImdMapScreen extends StatefulWidget {
  const ImdMapScreen({super.key});

  @override
  State<ImdMapScreen> createState() => _ImdMapScreenState();
}

class _ImdMapScreenState extends State<ImdMapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();

  MapBaseStyle _selectedBaseStyle = MapBaseStyle.osmLight;
  WeatherOverlayLayer _selectedOverlay = WeatherOverlayLayer.dopplerRadar;
  double _overlayOpacity = 0.75;
  bool _showRadarRangeCircles = true;
  bool _showStationMarkers = true;

  // Radar Timeline State
  List<RadarFrame> _radarFrames = [];
  int _currentFrameIndex = 0;
  bool _isPlaying = false;
  Timer? _playbackTimer;
  String _radarHost = 'https://tilecache.rainviewer.com';
  bool _isLoadingFrames = true;

  // Selected Station Callout
  ImdStation? _selectedStation;

  @override
  void initState() {
    super.initState();
    _loadRadarMetadata();
  }

  Future<void> _loadRadarMetadata() async {
    setState(() => _isLoadingFrames = true);
    final data = await RadarTileService.fetchLiveRadarMetadata();
    final past = (data['pastRadar'] as List<RadarFrame>?) ?? [];
    final nowcast = (data['nowcastRadar'] as List<RadarFrame>?) ?? [];
    final host = data['host'] as String? ?? 'https://tilecache.rainviewer.com';

    final allFrames = [...past, ...nowcast];
    if (mounted) {
      setState(() {
        _radarHost = host;
        _radarFrames = allFrames;
        _currentFrameIndex = past.isNotEmpty ? past.length - 1 : 0;
        _isLoadingFrames = false;
      });
    }
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _playbackTimer?.cancel();
      setState(() => _isPlaying = false);
    } else {
      if (_radarFrames.isEmpty) return;
      setState(() => _isPlaying = true);
      _playbackTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _currentFrameIndex = (_currentFrameIndex + 1) % _radarFrames.length;
        });
      });
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  String _getBaseMapUrl() {
    switch (_selectedBaseStyle) {
      case MapBaseStyle.osmLight:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapBaseStyle.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapBaseStyle.darkCarto:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}';
    }
  }

  String? _getOverlayTileUrl() {
    if (_selectedOverlay == WeatherOverlayLayer.none) return null;
    if (_selectedOverlay == WeatherOverlayLayer.dopplerRadar) {
      if (_radarFrames.isNotEmpty && _currentFrameIndex < _radarFrames.length) {
        final framePath = _radarFrames[_currentFrameIndex].path;
        return '$_radarHost$framePath/256/{z}/{x}/{y}/2/1_1.png';
      }
      return 'https://tilecache.rainviewer.com/v2/radar/now/256/{z}/{x}/{y}/2/1_1.png';
    }
    if (_selectedOverlay == WeatherOverlayLayer.satelliteClouds) {
      return 'https://tilecache.rainviewer.com/v2/satellite/now/256/{z}/{x}/{y}/0/0_0.png';
    }
    return null;
  }

  void _centerToUserLocation(WeatherProvider provider) async {
    _mapController.move(
      LatLng(provider.selectedCity.latitude, provider.selectedCity.longitude),
      9.0,
    );
    final success = await provider.fetchCurrentGpsLocation(promptPermission: true);
    if (mounted && success) {
      _mapController.move(
        LatLng(provider.selectedCity.latitude, provider.selectedCity.longitude),
        10.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context);
    final userPos = LatLng(provider.selectedCity.latitude, provider.selectedCity.longitude);
    final overlayUrl = _getOverlayTileUrl();

    String frameTimeStr = 'LIVE';
    if (_radarFrames.isNotEmpty && _currentFrameIndex < _radarFrames.length) {
      final ts = _radarFrames[_currentFrameIndex].timestamp;
      final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
      frameTimeStr = DateFormat('hh:mm a').format(dt);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      body: Stack(
        children: [
          // 1. FLUTTER MAP CORE
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userPos,
              initialZoom: 7.0,
              minZoom: 3.5,
              maxZoom: 17.0,
              onTap: (_, latlng) {
                setState(() => _selectedStation = null);
              },
            ),
            children: [
              // Base Map Layer
              TileLayer(
                urlTemplate: _getBaseMapUrl(),
                userAgentPackageName: 'in.gov.imd.mausam_x',
              ),

              // Doppler Weather Radar / Satellite Overlay Layer
              if (overlayUrl != null)
                TileLayer(
                  key: ValueKey('overlay_${_selectedOverlay}_$_currentFrameIndex'),
                  urlTemplate: overlayUrl,
                  userAgentPackageName: 'in.gov.imd.mausam_x',
                  tileBuilder: (context, tileWidget, tile) {
                    return Opacity(
                      opacity: _overlayOpacity,
                      child: tileWidget,
                    );
                  },
                ),

              // Doppler Radar 250km / 500km Range Scans
              if (_showRadarRangeCircles)
                CircleLayer(
                  circles: ImdStation.officialStations
                      .where((s) => s.type == ImdStationType.dopplerRadar)
                      .map((s) {
                    return CircleMarker(
                      point: LatLng(s.latitude, s.longitude),
                      radius: s.rangeKm * 1000, // radius in meters
                      useRadiusInMeter: true,
                      color: const Color(0xFF38BDF8).withAlpha(18),
                      borderColor: const Color(0xFF38BDF8).withAlpha(90),
                      borderStrokeWidth: 1.0,
                    );
                  }).toList(),
                ),

              // Station Markers Layer
              if (_showStationMarkers)
                MarkerLayer(
                  markers: [
                    // User Live Location Marker (Pulsing Radar Pin)
                    Marker(
                      point: userPos,
                      width: 44,
                      height: 44,
                      child: Tooltip(
                        message: 'Your Active Location: ${provider.selectedCity.name}',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF38BDF8).withAlpha(50),
                            border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.my_location, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),

                    // Official IMD DWR & AWS Stations
                    ...ImdStation.officialStations.map((station) {
                      final isSelected = _selectedStation?.name == station.name;
                      final isRadar = station.type == ImdStationType.dopplerRadar;

                      return Marker(
                        point: LatLng(station.latitude, station.longitude),
                        width: isSelected ? 48 : 36,
                        height: isSelected ? 48 : 36,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedStation = station);
                            _mapController.move(
                              LatLng(station.latitude, station.longitude),
                              _mapController.camera.zoom,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isRadar
                                  ? (isSelected ? const Color(0xFFF59E0B) : const Color(0xFF0284C7))
                                  : const Color(0xFF10B981),
                              border: Border.all(color: Colors.white, width: isSelected ? 2.5 : 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(90),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isRadar ? Icons.radar : Icons.wb_sunny,
                              color: Colors.white,
                              size: isSelected ? 24 : 18,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
            ],
          ),

          // 2. TOP HEADER BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: Row(
                children: [
                  // Back Button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF00224D).withAlpha(220),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Header Title & Active Overlay Indicator
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00224D).withAlpha(220),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.radar, color: Color(0xFF38BDF8), size: 16),
                              SizedBox(width: 6),
                              Text(
                                'IMD LIVE RADAR & SATELLITE',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedOverlay == WeatherOverlayLayer.dopplerRadar
                                ? 'Doppler Precipitation (dBZ) • $frameTimeStr'
                                : _selectedOverlay == WeatherOverlayLayer.satelliteClouds
                                    ? 'INSAT Cloud Cover • $frameTimeStr'
                                    : 'Surface Observatories & Stations',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF38BDF8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. RIGHT FLOATING ACTION BUTTONS
          Positioned(
            right: 14,
            top: 100,
            child: Column(
              children: [
                // Layer Control Button
                _buildFloatingButton(
                  icon: Icons.layers_outlined,
                  tooltip: 'Map Layers & Radar Feeds',
                  onTap: () => _showLayerControlSheet(context),
                  highlight: true,
                ),
                const SizedBox(height: 10),

                // My Location GPS Center
                _buildFloatingButton(
                  icon: Icons.my_location,
                  tooltip: 'Center to My Location',
                  onTap: () => _centerToUserLocation(provider),
                ),
                const SizedBox(height: 10),

                // Zoom In
                _buildFloatingButton(
                  icon: Icons.add,
                  tooltip: 'Zoom In',
                  onTap: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                ),
                const SizedBox(height: 6),

                // Zoom Out
                _buildFloatingButton(
                  icon: Icons.remove,
                  tooltip: 'Zoom Out',
                  onTap: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Toggle Range Rings
                _buildFloatingButton(
                  icon: Icons.track_changes,
                  tooltip: 'Toggle 250km Radar Ranges',
                  onTap: () {
                    setState(() => _showRadarRangeCircles = !_showRadarRangeCircles);
                  },
                  active: _showRadarRangeCircles,
                ),
              ],
            ),
          ),

          // 4. BOTTOM RADAR COLOR LEGEND BAR
          if (_selectedOverlay == WeatherOverlayLayer.dopplerRadar)
            Positioned(
              left: 14,
              right: 14,
              bottom: _selectedStation != null ? 220 : 110,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF001B3A).withAlpha(225),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rain Intensity (dBZ):', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
                        Text('Light → Extreme / Hail', style: TextStyle(fontSize: 10, color: Colors.white60)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF00E400), // Light Green
                              Color(0xFF009600), // Moderate Green
                              Color(0xFFFFEE00), // Yellow
                              Color(0xFFFF9900), // Orange
                              Color(0xFFFF0000), // Red Heavy
                              Color(0xFF99004C), // Purple Extreme
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 5. RADAR TIMELINE ANIMATION PLAYER (BOTTOM BAR)
          Positioned(
            left: 14,
            right: 14,
            bottom: _selectedStation != null ? 220 : 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF00224D).withAlpha(235),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(90),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Play / Pause Button
                      InkWell(
                        onTap: _togglePlayback,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF38BDF8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.black87,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Timestamp Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00142A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF38BDF8).withAlpha(120)),
                        ),
                        child: Text(
                          frameTimeStr,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Frame Timeline Slider
                      Expanded(
                        child: _isLoadingFrames
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF38BDF8)),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Fetching Doppler frames...', style: TextStyle(fontSize: 11, color: Colors.white70)),
                                ],
                              )
                            : _radarFrames.isEmpty
                                ? const Center(
                                    child: Text('Connecting to Doppler feeds...', style: TextStyle(fontSize: 11, color: Colors.white60)),
                                  )
                            : SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                  activeTrackColor: const Color(0xFF38BDF8),
                                  inactiveTrackColor: Colors.white24,
                                  thumbColor: Colors.white,
                                ),
                                child: Slider(
                                  value: _currentFrameIndex.toDouble().clamp(0, (_radarFrames.length - 1).toDouble()),
                                  min: 0,
                                  max: (_radarFrames.length - 1).toDouble(),
                                  divisions: _radarFrames.length > 1 ? _radarFrames.length - 1 : 1,
                                  onChanged: (val) {
                                    setState(() {
                                      _currentFrameIndex = val.round();
                                    });
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 6. SELECTED STATION FLOATING CALLOUT MODAL
          if (_selectedStation != null)
            Positioned(
              left: 14,
              right: 14,
              bottom: 16,
              child: _buildStationDetailsCard(_selectedStation!, provider),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool highlight = false,
    bool active = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: highlight
                  ? const Color(0xFF38BDF8)
                  : active
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF00224D).withAlpha(220),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(60),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: highlight ? Colors.black87 : Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStationDetailsCard(ImdStation station, WeatherProvider provider) {
    final isRadar = station.type == ImdStationType.dopplerRadar;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00224D).withAlpha(245),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF38BDF8).withAlpha(150), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isRadar ? const Color(0xFF0284C7).withAlpha(50) : const Color(0xFF10B981).withAlpha(50),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isRadar ? const Color(0xFF38BDF8) : const Color(0xFF34D399)),
                ),
                child: Icon(
                  isRadar ? Icons.radar : Icons.wb_sunny,
                  color: isRadar ? const Color(0xFF38BDF8) : const Color(0xFF34D399),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      '${station.state} • ${station.radarBand} (${station.rangeKm} km)',
                      style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                onPressed: () => setState(() => _selectedStation = null),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStationStat('Temperature', '${station.currentTempC ?? "--"}°C', Icons.thermostat),
              _buildStationStat('Air Quality', '${station.currentAqi ?? "--"} AQI', Icons.air),
              _buildStationStat('Rain Rate', '${station.currentRainMmH ?? 0.0} mm/h', Icons.water_drop),
              _buildStationStat('Status', station.status.split(' ').first, Icons.check_circle, isGood: true),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                provider.setCity(CityLocation(
                  name: station.name.split(' ').first,
                  state: station.state,
                  country: 'India',
                  latitude: station.latitude,
                  longitude: station.longitude,
                  localityDetail: '${station.name}, ${station.state}',
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Active location set to ${station.name}'),
                    backgroundColor: const Color(0xFF0284C7),
                  ),
                );
                setState(() => _selectedStation = null);
              },
              icon: const Icon(Icons.location_pin, size: 16),
              label: const Text('Set as Active Location in App'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationStat(String label, String value, IconData icon, {bool isGood = false}) {
    return Column(
      children: [
        Icon(icon, color: isGood ? const Color(0xFF34D399) : const Color(0xFF38BDF8), size: 16),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 9.5, color: Colors.white60)),
      ],
    );
  }

  void _showLayerControlSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF00224D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                  const Text('METEOROLOGICAL OVERLAY FEEDS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.0)),
                  const SizedBox(height: 10),

                  // Overlay Feed Selector Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildOverlayChip(
                        label: '🌧️ Doppler Weather Radar (DWR)',
                        layer: WeatherOverlayLayer.dopplerRadar,
                        setSheetState: setSheetState,
                      ),
                      _buildOverlayChip(
                        label: '🛰️ INSAT Satellite (Clouds)',
                        layer: WeatherOverlayLayer.satelliteClouds,
                        setSheetState: setSheetState,
                      ),
                      _buildOverlayChip(
                        label: '❌ No Weather Layer',
                        layer: WeatherOverlayLayer.none,
                        setSheetState: setSheetState,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Text('BASE MAP STYLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.0)),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _buildBaseStyleChoice(
                        title: 'Dark Carto',
                        style: MapBaseStyle.darkCarto,
                        setSheetState: setSheetState,
                      ),
                      const SizedBox(width: 8),
                      _buildBaseStyleChoice(
                        title: 'Satellite',
                        style: MapBaseStyle.satellite,
                        setSheetState: setSheetState,
                      ),
                      const SizedBox(width: 8),
                      _buildBaseStyleChoice(
                        title: 'Street OSM',
                        style: MapBaseStyle.osmLight,
                        setSheetState: setSheetState,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Layer Opacity:', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      Text('${(_overlayOpacity * 100).round()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
                    ],
                  ),
                  Slider(
                    value: _overlayOpacity,
                    min: 0.2,
                    max: 1.0,
                    activeColor: const Color(0xFF38BDF8),
                    onChanged: (val) {
                      setSheetState(() => _overlayOpacity = val);
                      setState(() => _overlayOpacity = val);
                    },
                  ),

                  const Divider(color: Colors.white12),

                  // Overlay Toggles
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text('Show IMD Radar Range Scan Rings (250km / 500km)', style: TextStyle(fontSize: 12, color: Colors.white)),
                    value: _showRadarRangeCircles,
                    activeThumbColor: const Color(0xFF38BDF8),
                    onChanged: (val) {
                      setSheetState(() => _showRadarRangeCircles = val);
                      setState(() => _showRadarRangeCircles = val);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text('Show IMD Doppler & AWS Station Pins', style: TextStyle(fontSize: 12, color: Colors.white)),
                    value: _showStationMarkers,
                    activeThumbColor: const Color(0xFF38BDF8),
                    onChanged: (val) {
                      setSheetState(() => _showStationMarkers = val);
                      setState(() => _showStationMarkers = val);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOverlayChip({
    required String label,
    required WeatherOverlayLayer layer,
    required StateSetter setSheetState,
  }) {
    final isSelected = _selectedOverlay == layer;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.black87 : Colors.white)),
      selected: isSelected,
      selectedColor: const Color(0xFF38BDF8),
      backgroundColor: const Color(0xFF00142A),
      onSelected: (sel) {
        if (sel) {
          setSheetState(() => _selectedOverlay = layer);
          setState(() => _selectedOverlay = layer);
        }
      },
    );
  }

  Widget _buildBaseStyleChoice({
    required String title,
    required MapBaseStyle style,
    required StateSetter setSheetState,
  }) {
    final isSelected = _selectedBaseStyle == style;
    return Expanded(
      child: InkWell(
        onTap: () {
          setSheetState(() => _selectedBaseStyle = style);
          setState(() => _selectedBaseStyle = style);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF00142A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? const Color(0xFF38BDF8) : Colors.white24),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black87 : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
