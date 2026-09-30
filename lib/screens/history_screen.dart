import 'package:flutter/material.dart';
import '../services/workout_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workout = WorkoutService();

    return ListenableBuilder(
      listenable: workout,
      builder: (context, _) {
        final history = workout.history;

        if (history.isEmpty) {
          return const Center(
            child: Text('Henüz kaydedilmiş antrenman geçmişi yok.', style: TextStyle(color: Colors.white54)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final session = history[index];
            final dateStr = '${session.date.day.toString().padLeft(2, '0')}.${session.date.month.toString().padLeft(2, '0')}.${session.date.year}';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(session.routineName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(6)),
                        child: Text(dateStr, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 14, color: Colors.cyanAccent),
                      const SizedBox(width: 4),
                      Text('${session.durationMinutes} dk', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 16),
                      const Icon(Icons.fitness_center, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('Toplam Hacim: ${session.totalVolume.toStringAsFixed(0)} kg',
                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: session.exercises.map((e) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(4)),
                        child: Text('${e.name} (${e.sets.length} set)', style: const TextStyle(color: Colors.white60, fontSize: 10)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
