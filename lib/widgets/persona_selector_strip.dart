import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/persona.dart';
import '../providers/weather_provider.dart';

class PersonaSelectorStrip extends StatelessWidget {
  const PersonaSelectorStrip({super.key});

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'sparkles':
        return Icons.auto_awesome;
      case 'heart_pulse':
        return Icons.favorite;
      case 'run':
        return Icons.directions_run;
      case 'waves':
        return Icons.waves;
      case 'airplane':
        return Icons.flight_takeoff;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'eco':
        return Icons.eco;
      case 'directions_car':
        return Icons.directions_car;
      case 'event':
        return Icons.event_available;
      default:
        return Icons.wb_sunny;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context);
    final activePersona = provider.selectedPersona;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PERSONALIZED HOMEPAGE MODES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'MoES / IMD Smart Engine',
                  style: TextStyle(fontSize: 10, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: PersonaInfo.allPersonas.length,
            separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final persona = PersonaInfo.allPersonas[index];
              final isSelected = persona.type == activePersona;

              return InkWell(
                onTap: () => provider.setPersona(persona.type),
                borderRadius: BorderRadius.circular(22),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                          )
                        : null,
                    color: isSelected ? null : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF334155),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withAlpha(100),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIconData(persona.iconName),
                        size: 16,
                        color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        persona.badgeText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
