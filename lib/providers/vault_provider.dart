import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../models/password_entry.dart';

class VaultProvider with ChangeNotifier {
  final List<PasswordEntry> _entries = [];
  String _vaultPin = '1234';
  final _storage = const FlutterSecureStorage();
  final LocalAuthentication _auth = LocalAuthentication();

  List<PasswordEntry> get entries => _entries;
  String get vaultPin => _vaultPin;

  VaultProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _vaultPin = await _storage.read(key: 'vault_pin') ?? '1234';
    final entriesJson = await _storage.read(key: 'vault_entries');
    if (entriesJson != null) {
      final List<dynamic> decoded = jsonDecode(entriesJson);
      _entries.clear();
      _entries.addAll(decoded.map((item) => PasswordEntry.fromJson(item)));
    }
    notifyListeners();
  }

  Future<void> _saveEntries() async {
    final entriesJson = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await _storage.write(key: 'vault_entries', value: entriesJson);
  }

  Future<void> updatePin(String newPin) async {
    await _storage.write(key: 'vault_pin', value: newPin);
    _vaultPin = newPin;
    notifyListeners();
  }

  Future<bool> authenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) return false;

      return await _auth.authenticate(
        localizedReason: 'Lütfen parmak izinizi taratın.',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  void addEntry(PasswordEntry entry) {
    _entries.add(entry);
    _saveEntries();
    notifyListeners();
  }

  void deleteEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    _saveEntries();
    notifyListeners();
  }
}
