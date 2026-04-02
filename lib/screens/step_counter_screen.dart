import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/step_provider.dart';
import '../providers/theme_provider.dart';
import 'package:intl/intl.dart';

class StepCounterScreen extends StatelessWidget {
  const StepCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Hareket'),
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
      body: Consumer<StepProvider>(
        builder: (context, provider, child) {
          final progress = provider.dailySteps / provider.dailyGoal;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepsCard(context, provider, progress),
                const SizedBox(height: 24),
                _buildStatsGrid(provider),
                const SizedBox(height: 32),
                const Text(
                  'Haftalık Özet (Son 7 Gün)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildHistoryList(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepsCard(BuildContext context, StepProvider provider, double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade300, Colors.deepOrange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'BUGÜN',
            style: TextStyle(color: Colors.white70, letterSpacing: 2, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 170,
                height: 170,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 15,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.directions_walk, color: Colors.white, size: 48),
                  Text(
                    '${provider.dailySteps}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' / ${provider.dailyGoal}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              progress >= 1.0 ? 'Hedef Başarıyla Tamamlandı!' : 'Adım atmaya devam edin!',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(StepProvider provider) {
    final distanceKm = (provider.dailySteps * 0.0007);
    final calories = (provider.dailySteps * 0.04);

    return Row(
      children: [
        Expanded(child: _buildStatItem(Icons.straighten, '${distanceKm.toStringAsFixed(1)}', 'KM', 'Mesafe')),
        const SizedBox(width: 16),
        Expanded(child: _buildStatItem(Icons.local_fire_department, '${calories.toStringAsFixed(0)}', 'Kcal', 'Kalori')),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String unit, String label) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(icon, color: Colors.orange.shade700, size: 30),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(width: 2),
                Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(StepProvider provider) {
    if (provider.history.isEmpty) {
      return const Center(child: Text('Henüz geçmiş veri yok.'));
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.history.length,
      itemBuilder: (context, index) {
        final item = provider.history[index];
        final date = DateTime.parse(item['date']);
        final dayFormat = DateFormat('EEEE');
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.orange.withOpacity(0.1)),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.event_available, color: Colors.orange.shade700),
            ),
            title: Text(
              item['date'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              '${item['steps']} Adım',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
