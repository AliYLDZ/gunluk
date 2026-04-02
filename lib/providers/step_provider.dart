import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepProvider with ChangeNotifier {
  int _currentSteps = 0;
  int _stepsAtStartOfDay = 0;
  int _dailyGoal = 5000;
  List<Map<String, dynamic>> _history = [];
  
  StreamSubscription<StepCount>? _stepCountStream;
  String _status = 'Bilinmiyor';

  int get currentSteps => _currentSteps;
  int get dailySteps => _currentSteps - _stepsAtStartOfDay > 0 ? _currentSteps - _stepsAtStartOfDay : 0;
  int get dailyGoal => _dailyGoal;
  String get status => _status;
  List<Map<String, dynamic>> get history => _history;

  StepProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadData();
    _startListening();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Tarih kontrolü
    final today = DateTime.now().toString().split(' ')[0];
    final lastResetDate = prefs.getString('last_reset_date') ?? '';

    // Geçmişi yükle
    final historyJson = prefs.getString('step_history') ?? '[]';
    _history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));

    if (lastResetDate != today) {
      // Gün değişmişse dünkü adımları geçmişe ekle (eğer kayıt varsa)
      if (lastResetDate.isNotEmpty) {
        final lastSteps = prefs.getInt('last_known_daily_steps') ?? 0;
        _addToHistory(lastResetDate, lastSteps);
      }
      
      // Yeni gün için sıfırla
      _stepsAtStartOfDay = _currentSteps; // Stream başladığında güncellenecek
      await prefs.setString('last_reset_date', today);
      await prefs.setInt('steps_at_start_of_day', _currentSteps);
    } else {
      _stepsAtStartOfDay = prefs.getInt('steps_at_start_of_day') ?? 0;
    }
    
    notifyListeners();
  }

  void _addToHistory(String date, int steps) {
    // Aynı tarihten varsa güncelle, yoksa ekle
    _history.removeWhere((item) => item['date'] == date);
    _history.insert(0, {'date': date, 'steps': steps});
    
    // Sadece son 7 günü tut
    if (_history.length > 7) {
      _history = _history.sublist(0, 7);
    }
    _saveHistory();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('step_history', jsonEncode(_history));
  }

  void _startListening() async {
    if (await Permission.activityRecognition.request().isGranted) {
      _stepCountStream = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
      );
    } else {
      _status = 'İzin Reddedildi';
      notifyListeners();
    }
  }

  void _onStepCount(StepCount event) async {
    _currentSteps = event.steps;
    
    final prefs = await SharedPreferences.getInstance();
    
    // Eğer stepsAtStartOfDay henüz set edilmemişse (ilk açılışta reboot sonrası)
    if (_stepsAtStartOfDay == 0 || _stepsAtStartOfDay > _currentSteps) {
      _stepsAtStartOfDay = _currentSteps;
      await prefs.setInt('steps_at_start_of_day', _stepsAtStartOfDay);
    }

    _status = 'Aktif';
    await prefs.setInt('last_known_daily_steps', dailySteps);
    notifyListeners();
  }

  void _onStepCountError(error) {
    _status = 'Hata: $error';
    notifyListeners();
  }

  @override
  void dispose() {
    _stepCountStream?.cancel();
    super.dispose();
  }
}
