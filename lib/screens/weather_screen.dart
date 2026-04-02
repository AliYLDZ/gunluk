import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/theme_provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında konuma göre hava durumunu getir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeatherByLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hava Durumu ve Saatler'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              context.read<ThemeProvider>().toggleTheme(!isDark);
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () => context.read<WeatherProvider>().fetchWeatherByLocation(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCitySearch(),
            const SizedBox(height: 20),
            Consumer<WeatherProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null) {
                  return Center(child: Text('Hata: ${provider.error}'));
                }
                if (provider.weather == null) {
                  return const Center(child: Text('Veri bulunamadı.'));
                }

                final weather = provider.weather!;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.blue.shade300, Colors.blue.shade700]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(weather.cityName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(weather.description.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 18)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                            width: 64,
                            height: 64,
                          ),
                          const SizedBox(width: 20),
                          Text('${weather.temperature.toStringAsFixed(1)}°C', 
                            style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        DateFormat('EEEE, d MMMM').format(DateTime.now()),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const Divider(color: Colors.white24, height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDetailItem(Icons.water_drop, 'Nem', '${weather.humidity}%'),
                          _buildDetailItem(Icons.air, 'Rüzgar', '${weather.windSpeed} m/s'),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Dünya Saatleri', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildWorldClock('İstanbul', 'GMT +3', DateTime.now()),
            _buildWorldClock('Londra', 'GMT +1', DateTime.now().subtract(const Duration(hours: 2))),
            _buildWorldClock('New York', 'GMT -4', DateTime.now().subtract(const Duration(hours: 7))),
            _buildWorldClock('Tokyo', 'GMT +9', DateTime.now().add(const Duration(hours: 6))),
          ],
        ),
      ),
    );
  }

  Widget _buildCitySearch() {
    return TextField(
      controller: _cityController,
      decoration: InputDecoration(
        hintText: 'Şehir veya ilçe ara...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            if (_cityController.text.isNotEmpty) {
              context.read<WeatherProvider>().fetchWeatherByCity(_cityController.text);
              _cityController.clear();
              FocusScope.of(context).unfocus();
            }
          },
        ),
      ),
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          context.read<WeatherProvider>().fetchWeatherByCity(value);
          _cityController.clear();
        }
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildWorldClock(String city, String timezone, DateTime time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(city, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(timezone),
        trailing: Text(
          DateFormat('HH:mm').format(time),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
