import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';

class WorkoutService extends ChangeNotifier {
  static final WorkoutService _instance = WorkoutService._internal();
  factory WorkoutService() => _instance;
  WorkoutService._internal();

  List<WorkoutSession> _history = [];
  int _waterIntakeMl = 1250;
  final int _dailyWaterGoalMl = 3000;
  bool _initialized = false;

  List<WorkoutSession> get history => List.unmodifiable(_history);
  int get waterIntakeMl => _waterIntakeMl;
  int get dailyWaterGoalMl => _dailyWaterGoalMl;
  double get waterProgress => (_waterIntakeMl / _dailyWaterGoalMl).clamp(0.0, 1.0);

  static const String _keyHistory = 'fitpulse_history_v1';
  static const String _keyWater = 'fitpulse_water_v1';

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();

    _waterIntakeMl = prefs.getInt(_keyWater) ?? 1250;

    final histStr = prefs.getString(_keyHistory);
    if (histStr != null && histStr.isNotEmpty) {
      _history = WorkoutSession.deserializeList(histStr);
    } else {
      _seedDefaultHistory();
      await _saveHistory();
    }

    _initialized = true;
    notifyListeners();
  }

  void _seedDefaultHistory() {
    final now = DateTime.now();
    _history = [
      WorkoutSession(
        id: 'ws_1',
        routineName: 'Push Günü (Göğüs & Omuz)',
        date: now.subtract(const Duration(days: 1)),
        durationMinutes: 52,
        exercises: [
          WorkoutExercise(
            id: 'e1',
            name: 'Barbell Bench Press',
            targetMuscle: 'Göğüs',
            sets: [
              ExerciseSet(setNumber: 1, weightKg: 70, reps: 10, isCompleted: true),
              ExerciseSet(setNumber: 2, weightKg: 80, reps: 8, isCompleted: true),
              ExerciseSet(setNumber: 3, weightKg: 85, reps: 6, isCompleted: true),
            ],
          ),
          WorkoutExercise(
            id: 'e2',
            name: 'Overhead Shoulder Press',
            targetMuscle: 'Omuz',
            sets: [
              ExerciseSet(setNumber: 1, weightKg: 45, reps: 10, isCompleted: true),
              ExerciseSet(setNumber: 2, weightKg: 50, reps: 8, isCompleted: true),
            ],
          ),
        ],
      ),
      WorkoutSession(
        id: 'ws_2',
        routineName: 'Pull Günü (Sırt & Biceps)',
        date: now.subtract(const Duration(days: 3)),
        durationMinutes: 48,
        exercises: [
          WorkoutExercise(
            id: 'e3',
            name: 'Barbell Deadlift',
            targetMuscle: 'Sırt',
            sets: [
              ExerciseSet(setNumber: 1, weightKg: 100, reps: 8, isCompleted: true),
              ExerciseSet(setNumber: 2, weightKg: 120, reps: 5, isCompleted: true),
            ],
          ),
          WorkoutExercise(
            id: 'e4',
            name: 'Barbell Biceps Curl',
            targetMuscle: 'Biceps',
            sets: [
              ExerciseSet(setNumber: 1, weightKg: 30, reps: 12, isCompleted: true),
              ExerciseSet(setNumber: 2, weightKg: 35, reps: 10, isCompleted: true),
            ],
          ),
        ],
      ),
    ];
  }

  // Pre-made routine generators
  List<WorkoutExercise> getRoutineExercises(String routine) {
    switch (routine) {
      case 'Push (İtiş)':
        return [
          WorkoutExercise(
            id: 'p_1',
            name: 'Barbell Bench Press',
            targetMuscle: 'Göğüs',
            sets: [
              ExerciseSet(setNumber: 1, weightKg: 60, reps: 10),
              ExerciseSet(setNumber: 2, weightKg: 70, reps: 8),
              ExerciseSet(setNumber: 3, weightKg: 80, reps: 6),
            ],
          ),
          WorkoutExercise(
            id: 'p_2',
            name: 'Incline Dumbbell Press',
            targetMuscle: 'Üst Göğüs',
            sets: [
              ExerciseSet(setNumber: 1, weightKg: 24, reps: 10),
              ExerciseSet(setNumber: 2, weightKg: 26, reps: 8),
            ],
          ),
          WorkoutExercise(
            id: 'p_3',
            name: 'Overhead Shoulder Press',
            targetMuscle: 'Omuz',
            sets: [
              ExerciseSet(setNumber: 1, weightKg: 40, reps: 10),
              ExerciseSet(setNumber: 2, weightKg: 45, reps: 8),
            ],
          ),
          WorkoutExercise(
            id: 'p_4',
            name: 'Triceps Cable Pushdown',
            targetMuscle: 'Triceps',
            sets: [
              ExerciseSet(setNumber: 1, weightKg: 25, reps: 12),
              ExerciseSet(setNumber: 2, weightKg: 30, reps: 10),
            ],
          ),
        ];

      case 'Pull (Çekiş)':
        return [
          WorkoutExercise(
            id: 'pl_1',
            name: 'Barbell Deadlift',
            targetMuscle: 'Sırt',
            sets: [
              ExerciseSet(setNumber: 1, weightKg: 90, reps: 8),
              ExerciseSet(setNumber: 2, weightKg: 110, reps: 5),
              ExerciseSet(setNumber: 3, weightKg: 120, reps: 3),
            ],
          ),
          WorkoutExercise(
            id: 'pl_2',
            name: 'Lat Pulldown',
            targetMuscle: 'Kanat / Sırt',
            sets: [
              ExerciseSet(setNumber: 1, weightKg: 55, reps: 10),
              ExerciseSet(setNumber: 2, weightKg: 65, reps: 8),
            ],
          ),
          WorkoutExercise(
            id: 'pl_3',
            name: 'Barbell Biceps Curl',
            targetMuscle: 'Biceps',
            sets: [
              ExerciseSet(setNumber: 1, weightKg: 30, reps: 10),
              ExerciseSet(setNumber: 2, weightKg: 35, reps: 8),
            ],
          ),
        ];

      case 'Legs (Bacak)':
      default:
        return [
          WorkoutExercise(
            id: 'lg_1',
            name: 'Barbell Back Squat',
            targetMuscle: 'Bacak / Quadriceps',
            sets: [
              ExerciseSet(setNumber: 1, weightKg: 80, reps: 10),
              ExerciseSet(setNumber: 2, weightKg: 90, reps: 8),
              ExerciseSet(setNumber: 3, weightKg: 100, reps: 6),
            ],
          ),
          WorkoutExercise(
            id: 'lg_2',
            name: 'Romanian Deadlift',
            targetMuscle: 'Hamstring / Kalça',
            sets: [
              ExerciseSet(setNumber: 1, weightKg: 60, reps: 10),
              ExerciseSet(setNumber: 2, weightKg: 70, reps: 8),
            ],
          ),
          WorkoutExercise(
            id: 'lg_3',
            name: 'Standing Calf Raise',
            targetMuscle: 'Kalf',
            sets: [
              ExerciseSet(setNumber: 1, weightKg: 40, reps: 15),
              ExerciseSet(setNumber: 2, weightKg: 50, reps: 12),
            ],
          ),
        ];
    }
  }

  Future<void> saveWorkout(WorkoutSession session) async {
    _history.insert(0, session);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> addWater(int ml) async {
    _waterIntakeMl = (_waterIntakeMl + ml).clamp(0, 10000);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWater, _waterIntakeMl);
    notifyListeners();
  }

  Future<void> resetWater() async {
    _waterIntakeMl = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWater, 0);
    notifyListeners();
  }

  // 1RM Calculation: Epley formula: weight * (1 + reps / 30)
  static double calculate1RM(double weight, int reps) {
    if (reps <= 0 || weight <= 0) return 0.0;
    if (reps == 1) return weight;
    return weight * (1 + (reps / 30.0));
  }

  // Barbell plate calculator: 20kg bar by default
  static Map<double, int> calculatePlates(double targetTotalWeightKg, {double barWeightKg = 20.0}) {
    if (targetTotalWeightKg <= barWeightKg) return {};
    double remainingPerSide = (targetTotalWeightKg - barWeightKg) / 2.0;

    final availablePlates = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25];
    final Map<double, int> result = {};

    for (final plate in availablePlates) {
      if (remainingPerSide >= plate) {
        int count = (remainingPerSide / plate).floor();
        result[plate] = count;
        remainingPerSide -= (count * plate);
      }
    }
    return result;
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHistory, WorkoutSession.serializeList(_history));
  }
}
