import 'dart:async';
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/workout_service.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  String _selectedRoutine = 'Push (İtiş)';
  late List<WorkoutExercise> _currentExercises;
  int _workoutSeconds = 0;
  Timer? _workoutTimer;

  // Rest Timer
  int _restSecondsRemaining = 0;
  Timer? _restTimer;

  @override
  void initState() {
    super.initState();
    _currentExercises = WorkoutService().getRoutineExercises(_selectedRoutine);
    _startWorkoutTimer();
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  void _startWorkoutTimer() {
    _workoutTimer?.cancel();
    _workoutSeconds = 0;
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _workoutSeconds++);
    });
  }

  void _changeRoutine(String routine) {
    setState(() {
      _selectedRoutine = routine;
      _currentExercises = WorkoutService().getRoutineExercises(routine);
      _startWorkoutTimer();
    });
  }

  void _triggerRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _restSecondsRemaining = seconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining > 0) {
        if (mounted) setState(() => _restSecondsRemaining--);
      } else {
        timer.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF06B6D4),
              content: Text('🔔 Dinlenme süresi bitti! Sıradaki sete başla!'),
            ),
          );
        }
      }
    });
  }

  void _finishWorkout() async {
    final durationMin = (_workoutSeconds / 60).ceil();
    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      routineName: _selectedRoutine,
      date: DateTime.now(),
      exercises: _currentExercises,
      durationMinutes: durationMin,
    );

    await WorkoutService().saveWorkout(session);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('🏆 Harika Antrenman!', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Antrenman Süresi: $durationMin dakika', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            Text('Kaldırılan Toplam Hacim: ${session.totalVolume.toStringAsFixed(0)} kg',
                style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06B6D4), foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              _changeRoutine(_selectedRoutine); // Reset
            },
            child: const Text('Kaydet ve Tamamla', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatTimer(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Routine Selector & Timer Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0E7490), Color(0xFF155E75)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRoutine,
                    dropdownColor: const Color(0xFF155E75),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    items: ['Push (İtiş)', 'Pull (Çekiş)', 'Legs (Bacak)'].map((r) {
                      return DropdownMenuItem(value: r, child: Text(r));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) _changeRoutine(val);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, size: 16, color: Colors.cyanAccent),
                      const SizedBox(width: 4),
                      Text(_formatTimer(_workoutSeconds),
                          style: const TextStyle(fontFamily: 'monospace', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Rest Timer Floating Bar if active
          if (_restSecondsRemaining > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('⏱️ ', style: TextStyle(fontSize: 18)),
                      Text('Set Arası Dinlenme: ${_restSecondsRemaining}s',
                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      _restTimer?.cancel();
                      setState(() => _restSecondsRemaining = 0);
                    },
                    child: const Text('Atla', style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ),

          // Exercises List
          ..._currentExercises.map((exercise) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                          Text(exercise.targetMuscle, style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 12)),
                        ],
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.cyanAccent,
                          side: const BorderSide(color: Colors.cyanAccent),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                        ),
                        onPressed: () => _triggerRestTimer(exercise.restSeconds),
                        icon: const Icon(Icons.timer_outlined, size: 14),
                        label: Text('${exercise.restSeconds}s Dinlen', style: const TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Sets Table
                  ...exercise.sets.map((set) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                            child: Center(
                              child: Text('${set.setNumber}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: set.weightKg > 0 ? '${set.weightKg}' : '',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                suffixText: 'kg',
                                hintText: 'Ağırlık',
                                hintStyle: const TextStyle(color: Colors.white38),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                              onChanged: (val) {
                                set.weightKg = double.tryParse(val) ?? 0.0;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: set.reps > 0 ? '${set.reps}' : '',
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                suffixText: 'tekrar',
                                hintText: 'Tekrar',
                                hintStyle: const TextStyle(color: Colors.white38),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                              onChanged: (val) {
                                set.reps = int.tryParse(val) ?? 0;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Checkbox(
                            value: set.isCompleted,
                            activeColor: const Color(0xFF06B6D4),
                            onChanged: (val) {
                              setState(() {
                                set.isCompleted = val ?? false;
                                if (set.isCompleted) {
                                  _triggerRestTimer(exercise.restSeconds);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),

          // Finish Workout Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06B6D4),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _finishWorkout,
            icon: const Icon(Icons.check_circle, size: 22),
            label: const Text('Antrenmanı Tamamla ve Kaydet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
