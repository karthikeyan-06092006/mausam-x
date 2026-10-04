import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/persona.dart';
import '../../providers/weather_provider.dart';
import '../../screens/imd_map_screen.dart';

class ImdDrawer extends StatelessWidget {
  const ImdDrawer({super.key});

  IconData _getPersonaIcon(PersonaType type) {
    switch (type) {
      case PersonaType.health:
        return Icons.favorite;
      case PersonaType.fitness:
        return Icons.directions_run;
      case PersonaType.beach:
        return Icons.waves;
      case PersonaType.traveler:
        return Icons.flight_takeoff;
      case PersonaType.family:
        return Icons.family_restroom;
      case PersonaType.agriculture:
        return Icons.eco;
      case PersonaType.commuter:
        return Icons.directions_car;
      case PersonaType.eventPlanner:
        return Icons.event_available;
      case PersonaType.general:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context);

    return Drawer(
      backgroundColor: const Color(0xFF003366),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF004080), Color(0xFF002244)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.wb_sunny, color: Color(0xFF004080), size: 28),
                ),
                const SizedBox(height: 10),
                const Text(
                  'MAUSAM (MoES / IMD)',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Personalized Meteorological System',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'METEOROLOGICAL RADAR & MAPS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white60, letterSpacing: 1.0),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.radar, color: Color(0xFF38BDF8)),
            title: const Text('Live Doppler Radar (DWR) Map', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('Rain reflectivity (dBZ) & Nowcast loop', style: TextStyle(color: Colors.white60, fontSize: 11.5)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ImdMapScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.satellite_alt, color: Color(0xFF34D399)),
            title: const Text('INSAT-3D Satellite Clouds', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Infrared & Visible cloud cover', style: TextStyle(color: Colors.white60, fontSize: 11.5)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ImdMapScreen()),
              );
            },
          ),
          const Divider(color: Colors.white24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'SELECT PERSONA VIEW',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white60, letterSpacing: 1.0),
            ),
          ),
          ...PersonaInfo.allPersonas.map((p) {
            final isSel = p.type == provider.selectedPersona;
            return ListTile(
              leading: Icon(_getPersonaIcon(p.type), color: isSel ? const Color(0xFF38BDF8) : Colors.white70),
              title: Text(
                p.title,
                style: TextStyle(
                  color: isSel ? const Color(0xFF38BDF8) : Colors.white,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSel ? const Icon(Icons.check_circle, color: Color(0xFF38BDF8), size: 18) : null,
              onTap: () {
                provider.setPersona(p.type);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}
