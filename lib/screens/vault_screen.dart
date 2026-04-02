import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vault_provider.dart';
import '../providers/theme_provider.dart';
import '../models/password_entry.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  bool _isAuthenticated = false;

  void _authenticate() {
    final pinController = TextEditingController();
    final currentPin = context.read<VaultProvider>().vaultPin;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Kasa Erişimi'),
        content: TextField(
          controller: pinController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'PIN Giriniz',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (pinController.text == currentPin) {
                setState(() => _isAuthenticated = true);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hatalı PIN!')),
                );
              }
            },
            child: const Text('Giriş'),
          ),
        ],
      ),
    );
  }

  void _showUpdatePinDialog() {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    final currentPin = context.read<VaultProvider>().vaultPin;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PIN Güncelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPinController,
              decoration: const InputDecoration(hintText: 'Mevcut PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: newPinController,
              decoration: const InputDecoration(hintText: 'Yeni PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              if (oldPinController.text == currentPin) {
                if (newPinController.text.length >= 4) {
                  await context.read<VaultProvider>().updatePin(newPinController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN başarıyla güncellendi.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yeni PIN en az 4 haneli olmalıdır.')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mevcut PIN hatalı!')),
                );
              }
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _showAddEntryDialog() {
    final appController = TextEditingController();
    final userController = TextEditingController();
    final passController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Şifre Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: appController, decoration: const InputDecoration(hintText: 'Uygulama Adı')),
            TextField(controller: userController, decoration: const InputDecoration(hintText: 'Kullanıcı Adı')),
            TextField(controller: passController, decoration: const InputDecoration(hintText: 'Şifre'), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              if (appController.text.isNotEmpty && passController.text.isNotEmpty) {
                final entry = PasswordEntry(
                  id: DateTime.now().toString(),
                  appName: appController.text,
                  username: userController.text,
                  password: passController.text,
                );
                context.read<VaultProvider>().addEntry(entry);
                Navigator.pop(context);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Şifre Kasası'),
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
          ],
        ),
        body: Center(
          child: ElevatedButton.icon(
            onPressed: _authenticate,
            icon: const Icon(Icons.lock_open),
            label: const Text('Kasanın Kilidini Aç'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifre Kasası'),
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
            icon: const Icon(Icons.settings),
            onPressed: _showUpdatePinDialog,
            tooltip: 'PIN Değiştir',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => setState(() => _isAuthenticated = false),
            tooltip: 'Kasayı Kilitle',
          ),
        ],
      ),
      body: Consumer<VaultProvider>(
        builder: (context, provider, child) {
          if (provider.entries.isEmpty) {
            return const Center(child: Text('Henüz kayıtlı şifre yok.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.entries.length,
            itemBuilder: (context, index) {
              final entry = provider.entries[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.vpn_key),
                  title: Text(entry.appName),
                  subtitle: Text(entry.username),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => provider.deleteEntry(entry.id),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(entry.appName),
                        content: Text('Şifre: ${entry.password}'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat')),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEntryDialog,
        icon: const Icon(Icons.add),
        label: const Text('Şifre Ekle'),
      ),
    );
  }
}
