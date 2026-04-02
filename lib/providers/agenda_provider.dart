import 'package:flutter/material.dart';
import '../models/task.dart';

class AgendaProvider with ChangeNotifier {
  final List<Task> _tasks = [];
  
  List<Task> get tasks => _tasks;

  List<Task> getTasksForDay(DateTime day) {
    return _tasks.where((task) => 
      task.date.year == day.year && 
      task.date.month == day.month && 
      task.date.day == day.day
    ).toList();
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void addBulkTasks(String title, List<int> selectedWeekdays, DateTime endDate) {
    DateTime current = DateTime.now();
    current = DateTime(current.year, current.month, current.day);
    final normalizedEndDate = DateTime(endDate.year, endDate.month, endDate.day);

    while (current.isBefore(normalizedEndDate) || current.isAtSameMomentAs(normalizedEndDate)) {
      if (selectedWeekdays.contains(current.weekday)) {
        _tasks.add(Task(
          id: '${DateTime.now().millisecondsSinceEpoch}_${current.millisecondsSinceEpoch}',
          title: title,
          date: current,
        ));
      }
      current = current.add(const Duration(days: 1));
    }
    notifyListeners();
  }

  void toggleTaskStatus(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].isDone = !_tasks[index].isDone;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}
