import 'package:flutter/material.dart';
import '../../services/workout_service.dart';

class OneRepMaxScreen extends StatefulWidget {
  const OneRepMaxScreen({super.key});

  @override
  State<OneRepMaxScreen> createState() => _OneRepMaxScreenState();
}

class _OneRepMaxScreenState extends State<OneRepMaxScreen> {
  final TextEditingController _weightController = TextEditingController(text: '80');
  final TextEditingController _repsController = TextEditingController(text: '6');

  double _calculated1RM = 0.0;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _recalculate() {
    final w = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final r = int.tryParse(_repsController.text.trim()) ?? 0;
    setState(() {
      _calculated1RM = WorkoutService.calculate1RM(w, r);
    });
  }

  @override
  Widget build(BuildContext context) {
    final percentages = [
      {'pct': 95, 'reps': '1-2 Tekrar (Maksimum Güç)'},
      {'pct': 90, 'reps': '3-4 Tekrar (Kuvvet)'},
      {'pct': 85, 'reps': '5-6 Tekrar (Kuvvet & Hipertrofi)'},
      {'pct': 80, 'reps': '7-8 Tekrar (Kas Büyümesi)'},
      {'pct': 75, 'reps': '9-10 Tekrar (Hipertrofi)'},
      {'pct': 70, 'reps': '11-12 Tekrar (Dayanıklılık)'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏋️ 1RM (Tek Tekrar Maksimumu)'),
        backgroundColor: const Color(0xFF0F172A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Inputs Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    onChanged: (_) => _recalculate(),
                    decoration: InputDecoration(
                      labelText: 'Ağırlık (kg)',
                      labelStyle: const TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    onChanged: (_) => _recalculate(),
                    decoration: InputDecoration(
                      labelText: 'Tekrar Sayısı',
                      labelStyle: const TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Big 1RM Result Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0E7490), Color(0xFF155E75)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  const Text('Tahmini 1RM (Tek Tekrar Maksimum)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    '${_calculated1RM.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text('Epley Formülü ile bilimsel olarak hesaplandı', style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Percentages Table
            const Text('Hedef Çalışma Ağırlıkları:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),

            ...percentages.map((p) {
              final pct = p['pct'] as int;
              final targetWeight = _calculated1RM * (pct / 100.0);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('%$pct 1RM', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent, fontSize: 14)),
                        Text(p['reps'] as String, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                    Text(
                      '${targetWeight.toStringAsFixed(1)} kg',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
