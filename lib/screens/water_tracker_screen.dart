import 'package:flutter/material.dart';
import '../services/workout_service.dart';

class WaterTrackerScreen extends StatelessWidget {
  const WaterTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workout = WorkoutService();

    return ListenableBuilder(
      listenable: workout,
      builder: (context, _) {
        final currentMl = workout.waterIntakeMl;
        final goalMl = workout.dailyWaterGoalMl;
        final progress = workout.waterProgress;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Water Display Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0369A1), Color(0xFF0C4A6E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    const Text('💧 Günlük Su Tüketimi', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 12),
                    Text(
                      '$currentMl ml',
                      style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'Hedef: $goalMl ml (%${(progress * 100).toInt()})',
                      style: const TextStyle(color: Colors.cyanAccent, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Quick Add Buttons
              const Text('Hızlı Ekle:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildWaterAddButton(workout, 250, '🥛 250 ml\n(1 Bardak)'),
                  const SizedBox(width: 10),
                  _buildWaterAddButton(workout, 500, '🍶 500 ml\n(Küçük Şişe)'),
                  const SizedBox(width: 10),
                  _buildWaterAddButton(workout, 1000, '🧊 1000 ml\n(1 Litre)'),
                ],
              ),
              const SizedBox(height: 20),

              // Reset Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => workout.resetWater(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Günü Sıfırla'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWaterAddButton(WorkoutService service, int ml, String label) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: Colors.cyanAccent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF0284C7)),
          ),
        ),
        onPressed: () => service.addWater(ml),
        child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}
