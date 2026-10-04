import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/persona.dart';
import '../providers/weather_provider.dart';
import '../widgets/imd/imd_top_bar.dart';
import '../widgets/imd/imd_hero_weather.dart';
import '../widgets/imd/imd_aqi_pill.dart';
import '../widgets/imd/imd_three_hourly_card.dart';
import '../widgets/imd/imd_quick_action_buttons.dart';
import '../widgets/imd/imd_district_warning_card.dart';
import '../widgets/imd/imd_seven_day_forecast_card.dart';
import '../widgets/imd/imd_sun_moon_card.dart';
import '../widgets/imd/imd_smart_activity_card.dart';
import '../widgets/imd/imd_drawer.dart';
import '../widgets/persona_cards/health_card.dart';
import '../widgets/persona_cards/fitness_card.dart';
import '../widgets/persona_cards/marine_card.dart';
import '../widgets/persona_cards/traveler_card.dart';
import '../widgets/persona_cards/family_card.dart';
import '../widgets/persona_cards/agromet_card.dart';
import '../widgets/persona_cards/commuter_card.dart';
import '../widgets/persona_cards/event_planner_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WeatherProvider>(context, listen: false);
      provider.fetchCurrentGpsLocation(promptPermission: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const ImdDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0058B6), // IMD Sky Blue Top
              Color(0xFF003875), // Deep Navy Blue Middle
              Color(0xFF00224D), // Bottom Blue
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => provider.loadWeatherData(),
            color: Colors.white,
            backgroundColor: const Color(0xFF003875),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. Top Header Bar (Location, Date, Menu, GPS, Search)
                SliverToBoxAdapter(
                  child: ImdTopBar(
                    onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                ),

                // Loading State
                if (provider.weatherData == null && provider.errorMessage == null)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Fetching live IMD meteorological data...',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (provider.errorMessage != null && provider.weatherData == null)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_off, size: 48, color: Colors.white70),
                            const SizedBox(height: 12),
                            Text(
                              'Connection Error: ${provider.errorMessage}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => provider.loadWeatherData(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF003875),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (provider.weatherData != null) ...[
                  // 2. Weather Hero & Wind Compass Dial
                  SliverToBoxAdapter(
                    child: ImdHeroWeather(weather: provider.weatherData!),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 10),
                  ),

                  // 3. CPCB National AQI Pill
                  SliverToBoxAdapter(
                    child: Center(
                      child: ImdAqiPill(aqiData: provider.aqiData),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 10),
                  ),

                  // 4. Step 2 Core: Smart Activity Feasibility Card (Recommendation + Dropdown)
                  const SliverToBoxAdapter(
                    child: ImdSmartActivityCard(),
                  ),

                  // 5. 3-Hourly Forecast Card
                  SliverToBoxAdapter(
                    child: ImdThreeHourlyCard(
                      hourlyList: provider.weatherData!.hourlyForecast,
                    ),
                  ),

                  // 6. Agromet & Crowd Source Quick Action Buttons
                  SliverToBoxAdapter(
                    child: ImdQuickActionButtons(
                      onAgrometTap: () => provider.setPersona(PersonaType.agriculture),
                      onCrowdSourceTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Crowd-sourced local weather reporting portal active.')),
                        );
                      },
                    ),
                  ),

                  // 7. District Warning & Nowcast Card
                  SliverToBoxAdapter(
                    child: ImdDistrictWarningCard(
                      districtName: provider.selectedCity.name,
                      weather: provider.weatherData!,
                    ),
                  ),

                  // 8. 7-Day Temperature Range Slider Forecast Card
                  SliverToBoxAdapter(
                    child: ImdSevenDayForecastCard(
                      dailyList: provider.weatherData!.dailyForecast,
                    ),
                  ),

                  // 9. Sun & Moon Arc Trajectory Cards
                  SliverToBoxAdapter(
                    child: ImdSunMoonCard(weather: provider.weatherData!),
                  ),

                  // 10. Selected Persona Specific Cards (If persona chosen from drawer)
                  if (provider.selectedPersona != PersonaType.general)
                    SliverToBoxAdapter(
                      child: _buildCustomPersonaCard(provider),
                    ),

                  // Footer
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      alignment: Alignment.center,
                      child: const Column(
                        children: [
                          Text(
                            'Ministry of Earth Sciences (MoES) • Government of India',
                            style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'India Meteorological Department • National Weather Service',
                            style: TextStyle(fontSize: 10, color: Colors.white38),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomPersonaCard(WeatherProvider provider) {
    final weather = provider.weatherData!;
    final aqi = provider.aqiData;
    final marine = provider.marineData;
    final agromet = provider.agrometData;
    final city = provider.selectedCity;

    switch (provider.selectedPersona) {
      case PersonaType.health:
        return aqi != null ? HealthCard(aqi: aqi) : const SizedBox.shrink();
      case PersonaType.fitness:
        return FitnessCard(weather: weather, aqi: aqi);
      case PersonaType.beach:
        return marine != null ? MarineCard(marine: marine, cityName: city.name) : const SizedBox.shrink();
      case PersonaType.traveler:
        return TravelerCard(weather: weather, currentCity: city.name);
      case PersonaType.family:
        return FamilyCard(weather: weather);
      case PersonaType.agriculture:
        return agromet != null ? AgrometCard(agromet: agromet, weather: weather) : const SizedBox.shrink();
      case PersonaType.commuter:
        return CommuterCard(weather: weather);
      case PersonaType.eventPlanner:
        return EventPlannerCard(weather: weather);
      case PersonaType.general:
        return const SizedBox.shrink();
    }
  }
}
