import 'package:flutter/material.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finans ve Borsa')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFinanceCard('Döviz', [
            _buildFinanceItem('USD/TRY', '27.45', '+0.15%'),
            _buildFinanceItem('EUR/TRY', '29.30', '-0.05%'),
            _buildFinanceItem('GBP/TRY', '34.12', '+0.22%'),
          ]),
          const SizedBox(height: 16),
          _buildFinanceCard('Altın', [
            _buildFinanceItem('Gram Altın', '1,675.00', '+1.10%'),
            _buildFinanceItem('Çeyrek Altın', '2,750.00', '+1.05%'),
            _buildFinanceItem('Ons Altın', '1,920.00', '-0.30%'),
          ]),
          const SizedBox(height: 16),
          _buildFinanceCard('Borsa (BIST)', [
            _buildFinanceItem('BIST 100', '7,850.45', '+2.45%'),
            _buildFinanceItem('THYAO', '245.30', '+3.15%'),
            _buildFinanceItem('ASELS', '78.90', '-1.20%'),
          ]),
        ],
      ),
    );
  }

  Widget _buildFinanceCard(String title, List<Widget> items) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceItem(String name, String value, String change) {
    final bool isPositive = change.startsWith('+');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(width: 10),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
