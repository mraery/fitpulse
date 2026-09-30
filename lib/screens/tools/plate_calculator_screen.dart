import 'package:flutter/material.dart';
import '../../services/workout_service.dart';

class PlateCalculatorScreen extends StatefulWidget {
  const PlateCalculatorScreen({super.key});

  @override
  State<PlateCalculatorScreen> createState() => _PlateCalculatorScreenState();
}

class _PlateCalculatorScreenState extends State<PlateCalculatorScreen> {
  final TextEditingController _weightController = TextEditingController(text: '100');
  double _barWeight = 20.0;
  Map<double, int> _platesPerSide = {};

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _recalculate() {
    final target = double.tryParse(_weightController.text.trim()) ?? 0.0;
    setState(() {
      _platesPerSide = WorkoutService.calculatePlates(target, barWeightKg: _barWeight);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧮 Barbell Plaka Hesaplayıcı'),
        backgroundColor: const Color(0xFF0F172A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bar weight selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bar Ağırlığı:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment(value: 20.0, label: Text('20 kg (Olimpik)')),
                    ButtonSegment(value: 15.0, label: Text('15 kg')),
                    ButtonSegment(value: 10.0, label: Text('10 kg')),
                  ],
                  selected: {_barWeight},
                  onSelectionChanged: (val) {
                    setState(() {
                      _barWeight = val.first;
                      _recalculate();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Target Weight input
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              onChanged: (_) => _recalculate(),
              decoration: InputDecoration(
                labelText: 'Hedef Toplam Ağırlık (Bar Dahil)',
                suffixText: 'kg',
                suffixStyle: const TextStyle(color: Colors.cyanAccent, fontSize: 18),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // Barbell visual diagram representation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text('Her Bir Tarafa Takılacak Plakalar', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  if (_platesPerSide.isEmpty)
                    const Text('Hedef ağırlık bar ağırlığına eşit veya daha küçük.', style: TextStyle(color: Colors.white38, fontSize: 12))
                  else
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: _platesPerSide.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E7490).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.cyanAccent),
                          ),
                          child: Column(
                            children: [
                              Text('${entry.key} kg', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('${entry.value} adet', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
