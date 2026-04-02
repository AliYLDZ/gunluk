import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/agenda_provider.dart';

class BulkAddTaskDialog extends StatefulWidget {
  const BulkAddTaskDialog({super.key});

  @override
  State<BulkAddTaskDialog> createState() => _BulkAddTaskDialogState();
}

class _BulkAddTaskDialogState extends State<BulkAddTaskDialog> {
  final _titleController = TextEditingController();
  final List<int> _selectedWeekdays = [];
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  final List<Map<String, dynamic>> _weekdays = [
    {'name': 'Pazartesi', 'value': DateTime.monday},
    {'name': 'Salı', 'value': DateTime.tuesday},
    {'name': 'Çarşamba', 'value': DateTime.wednesday},
    {'name': 'Perşembe', 'value': DateTime.thursday},
    {'name': 'Cuma', 'value': DateTime.friday},
    {'name': 'Cumartesi', 'value': DateTime.saturday},
    {'name': 'Pazar', 'value': DateTime.sunday},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Toplu Görev Ekle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Görev Başlığı',
                hintText: 'Örn: Sabah Yürüyüşü',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tekrarlanacak Günler:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: _weekdays.map((day) {
                final isSelected = _selectedWeekdays.contains(day['value']);
                return FilterChip(
                  label: Text(day['name']),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedWeekdays.add(day['value']);
                      } else {
                        _selectedWeekdays.remove(day['value']);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const Divider(height: 32),
            InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (pickedDate != null) {
                  setState(() => _endDate = pickedDate);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.blueGrey),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bitiş Tarihi', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          DateFormat('dd.MM.yyyy').format(_endDate),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.edit, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty && _selectedWeekdays.isNotEmpty) {
              context.read<AgendaProvider>().addBulkTasks(
                _titleController.text,
                _selectedWeekdays,
                _endDate,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Görevler başarıyla oluşturuldu.')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lütfen başlık girin ve en az bir gün seçin.')),
              );
            }
          },
          child: const Text('Oluştur'),
        ),
      ],
    );
  }
}
