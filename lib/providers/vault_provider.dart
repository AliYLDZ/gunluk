import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/password_entry.dart';

class VaultProvider with ChangeNotifier {
  final List<PasswordEntry> _entries = [];
  String _vaultPin = '1234';
  
  List<PasswordEntry> get entries => _entries;
  String get vaultPin => _vaultPin;

  VaultProvider() {
    _loadPin();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    _vaultPin = prefs.getString('vault_pin') ?? '1234';
    notifyListeners();
  }

  Future<void> updatePin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vault_pin', newPin);
    _vaultPin = newPin;
    notifyListeners();
  }

  void addEntry(PasswordEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  void deleteEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }
}
