import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/weather_data.dart';

class WeatherProvider with ChangeNotifier {
  WeatherData? _weather;
  bool _isLoading = false;
  String? _error;
  
  // Önemli: Gerçek bir uygulama için openweathermap.org'dan ücretsiz API KEY almalısınız.
  final String _apiKey = 'b6907d289e10d714a6e88b30761fae22'; // Örnek anahtar (Sınırlı olabilir)

  WeatherData? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeatherByLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Konum servisleri kapalı.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Konum izni reddedildi.';
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      final url = 'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric&lang=tr';
      
      await _getWeatherData(url);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeatherByCity(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric&lang=tr';
      await _getWeatherData(url);
    } catch (e) {
      _error = 'Şehir bulunamadı veya bir hata oluştu.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getWeatherData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      _weather = WeatherData.fromJson(json.decode(response.body));
    } else {
      throw 'Hava durumu verileri alınamadı.';
    }
  }
}
