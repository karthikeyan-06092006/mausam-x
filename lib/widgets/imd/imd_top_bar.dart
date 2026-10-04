import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/weather_provider.dart';
import '../../services/weather_service.dart';
import '../../screens/imd_map_screen.dart';

class ImdTopBar extends StatelessWidget {
  final VoidCallback onOpenDrawer;

  const ImdTopBar({super.key, required this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context);
    final city = provider.selectedCity;
    final currentDateStr = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Row(
        children: [
          // Hamburger Menu Icon
          IconButton(
            onPressed: onOpenDrawer,
            icon: const Icon(Icons.menu, color: Colors.white, size: 26),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),

          // Location Title & Date Subtitle
          Expanded(
            child: InkWell(
              onTap: () => _showSearchModal(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    city.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentDateStr,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Live Radar Map Button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ImdMapScreen()),
              );
            },
            icon: const Icon(Icons.radar, color: Color(0xFF38BDF8), size: 23),
            tooltip: 'IMD Doppler Weather Radar Map',
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),

          // GPS Location auto-detect button
          IconButton(
            onPressed: provider.isLocating
                ? null
                : () async {
                    final success = await provider.fetchCurrentGpsLocation(promptPermission: true);
                    if (!context.mounted) return;
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('📍 Location updated: ${provider.selectedCity.displayName}'),
                          backgroundColor: const Color(0xFF0284C7),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    } else {
                      final isGpsOn = await Geolocator.isLocationServiceEnabled();
                      if (!context.mounted) return;
                      if (!isGpsOn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Device GPS / Location is turned OFF.'),
                            backgroundColor: const Color(0xFFD97706),
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'ENABLE GPS',
                              textColor: Colors.white,
                              onPressed: () => Geolocator.openLocationSettings(),
                            ),
                          ),
                        );
                        return;
                      }

                      final permission = await Geolocator.checkPermission();
                      if (!context.mounted) return;
                      if (permission == LocationPermission.deniedForever) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Location permission is denied in Settings.'),
                            backgroundColor: const Color(0xFFDC2626),
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'SETTINGS',
                              textColor: Colors.white,
                              onPressed: () => Geolocator.openAppSettings(),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please grant location permission to detect your current location.'),
                            backgroundColor: Color(0xFFD97706),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
            icon: provider.isLocating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.my_location, color: Colors.white, size: 22),
            tooltip: 'Get Current GPS Location',
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),

          // Search button
          IconButton(
            onPressed: () => _showSearchModal(context),
            icon: const Icon(Icons.search, color: Colors.white, size: 23),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showSearchModal(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context, listen: false);
    final searchCtrl = TextEditingController();
    List<CityLocation> searchResults = CityLocation.popularIndianCities;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF003875),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Search District / City in India',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search city (e.g. Coimbatore, Delhi, Pune...)',
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF00224D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) async {
                        final res = await provider.searchCities(val);
                        setModalState(() {
                          searchResults = res;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    ListTile(
                      leading: const Icon(Icons.my_location, color: Color(0xFF38BDF8)),
                      title: const Text('Use Current GPS Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Auto-detect latitude & longitude', style: TextStyle(color: Colors.white60, fontSize: 12)),
                      onTap: () {
                        provider.fetchCurrentGpsLocation();
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(color: Colors.white24),
                    Expanded(
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, idx) {
                          final item = searchResults[idx];
                          final isSel = item.name == provider.selectedCity.name;
                          return ListTile(
                            leading: Icon(
                              item.isCoastal ? Icons.waves : Icons.location_on,
                              color: isSel ? const Color(0xFF38BDF8) : Colors.white60,
                            ),
                            title: Text(
                              item.displayName,
                              style: TextStyle(
                                color: isSel ? const Color(0xFF38BDF8) : Colors.white,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text('${item.state}, ${item.country}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            onTap: () {
                              provider.setCity(item);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
