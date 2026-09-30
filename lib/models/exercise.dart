import 'dart:convert';

class ExerciseSet {
  int setNumber;
  double weightKg;
  int reps;
  bool isCompleted;

  ExerciseSet({
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'setNumber': setNumber,
        'weightKg': weightKg,
        'reps': reps,
        'isCompleted': isCompleted,
      };

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => ExerciseSet(
        setNumber: json['setNumber'] ?? 1,
        weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
        reps: json['reps'] ?? 0,
        isCompleted: json['isCompleted'] ?? false,
      );
}

class WorkoutExercise {
  final String id;
  final String name;
  final String targetMuscle;
  final List<ExerciseSet> sets;
  final int restSeconds;

  WorkoutExercise({
    required this.id,
    required this.name,
    required this.targetMuscle,
    required this.sets,
    this.restSeconds = 90,
  });

  double get volume => sets
      .where((s) => s.isCompleted)
      .fold(0.0, (acc, s) => acc + (s.weightKg * s.reps));

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'targetMuscle': targetMuscle,
        'sets': sets.map((s) => s.toJson()).toList(),
        'restSeconds': restSeconds,
      };

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) => WorkoutExercise(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        targetMuscle: json['targetMuscle'] ?? 'Tüm Vücut',
        sets: json['sets'] != null
            ? (json['sets'] as List).map((s) => ExerciseSet.fromJson(s)).toList()
            : [],
        restSeconds: json['restSeconds'] ?? 90,
      );
}

class WorkoutSession {
  final String id;
  final String routineName;
  final DateTime date;
  final List<WorkoutExercise> exercises;
  final int durationMinutes;

  WorkoutSession({
    required this.id,
    required this.routineName,
    required this.date,
    required this.exercises,
    required this.durationMinutes,
  });

  double get totalVolume =>
      exercises.fold(0.0, (acc, ex) => acc + ex.volume);

  Map<String, dynamic> toJson() => {
        'id': id,
        'routineName': routineName,
        'date': date.toIso8601String(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'durationMinutes': durationMinutes,
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
        id: json['id'] ?? '',
        routineName: json['routineName'] ?? 'Antrenman',
        date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
        exercises: json['exercises'] != null
            ? (json['exercises'] as List)
                .map((e) => WorkoutExercise.fromJson(e))
                .toList()
            : [],
        durationMinutes: json['durationMinutes'] ?? 45,
      );

  static String serializeList(List<WorkoutSession> list) =>
      jsonEncode(list.map((w) => w.toJson()).toList());

  static List<WorkoutSession> deserializeList(String str) {
    try {
      final decoded = jsonDecode(str) as List;
      return decoded.map((w) => WorkoutSession.fromJson(w)).toList();
    } catch (_) {
      return [];
    }
  }
}
