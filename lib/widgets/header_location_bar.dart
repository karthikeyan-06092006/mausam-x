import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../services/weather_service.dart';

class HeaderLocationBar extends StatelessWidget {
  const HeaderLocationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context);
    final city = provider.selectedCity;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // City Name & MoES Badge
          Expanded(
            child: InkWell(
              onTap: () => _showCitySearchDialog(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF38BDF8), size: 20),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            city.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
                      ],
                    ),
                    Text(
                      '${city.state}, ${city.country} • IMD Live Feed',
                      style: const TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Refresh button & Search icon
          Row(
            children: [
              IconButton(
                onPressed: provider.isLoading ? null : () => provider.loadWeatherData(),
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF38BDF8)),
                      )
                    : const Icon(Icons.refresh, color: Colors.white70),
                tooltip: 'Refresh live meteorological data',
              ),
              IconButton(
                onPressed: () => _showCitySearchDialog(context),
                icon: const Icon(Icons.search, color: Color(0xFF38BDF8)),
                tooltip: 'Search City',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCitySearchDialog(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context, listen: false);
    final searchController = TextEditingController();
    List<CityLocation> searchResults = CityLocation.popularIndianCities;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      'Select Indian City or Search',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search city (e.g. Pune, Shimla, Jaipur...)',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF38BDF8)),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF334155)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF334155)),
                        ),
                      ),
                      onChanged: (val) async {
                        final results = await provider.searchCities(val);
                        setModalState(() {
                          searchResults = results;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cities & Locations',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white60),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, idx) {
                          final item = searchResults[idx];
                          final isSelected = item.name == provider.selectedCity.name;
                          return ListTile(
                            leading: Icon(
                              item.isCoastal ? Icons.waves : Icons.location_city,
                              color: isSelected ? const Color(0xFF38BDF8) : Colors.white60,
                            ),
                            title: Text(
                              item.name,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF38BDF8) : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              '${item.state}, ${item.country}',
                              style: const TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Color(0xFF38BDF8), size: 20)
                                : null,
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
