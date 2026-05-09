import 'package:uuid/uuid.dart';

/// A single quiz question with multiple-choice options.
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  QuizQuestion({
    String? id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  }) : id = id ?? const Uuid().v4();

  /// Check if the selected index is the correct answer.
  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;

  String get correctAnswer => options[correctIndex];

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      correctIndex: json['correct_index'] as int,
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'correct_index': correctIndex,
        'explanation': explanation,
      };
}

/// A quiz track = a subject with a list of questions.
class QuizTrack {
  final String id;
  final String subject; // "Math", "Physics", "English"
  final String title;
  final String description;
  final int difficulty; // 1-5
  final List<QuizQuestion> questions;
  final int xpPerQuestion; // XP earned per correct answer

  QuizTrack({
    String? id,
    required this.subject,
    required this.title,
    this.description = '',
    this.difficulty = 1,
    required this.questions,
    this.xpPerQuestion = 10,
  }) : id = id ?? const Uuid().v4();

  int get totalQuestions => questions.length;
  int get maxXp => totalQuestions * xpPerQuestion;

  factory QuizTrack.fromJson(Map<String, dynamic> json) {
    return QuizTrack(
      id: json['id'] as String,
      subject: json['subject'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      difficulty: json['difficulty'] as int? ?? 1,
      questions: (json['questions'] as List<dynamic>)
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      xpPerQuestion: json['xp_per_question'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'title': title,
        'description': description,
        'difficulty': difficulty,
        'questions': questions.map((q) => q.toJson()).toList(),
        'xp_per_question': xpPerQuestion,
      };
}

/// Tracks a user's progress through a specific quiz track.
class QuizProgress {
  final String userId;
  final String trackId;
  final String subject;
  int currentIndex;
  int correctAnswers;
  int xpEarned;
  bool isCompleted;
  DateTime? completedAt;

  QuizProgress({
    required this.userId,
    required this.trackId,
    required this.subject,
    this.currentIndex = 0,
    this.correctAnswers = 0,
    this.xpEarned = 0,
    this.isCompleted = false,
    this.completedAt,
  });

  double get accuracy =>
      currentIndex > 0 ? correctAnswers / currentIndex : 0.0;

  factory QuizProgress.fromJson(Map<String, dynamic> json) {
    return QuizProgress(
      userId: json['user_id'] as String,
      trackId: json['track_id'] as String,
      subject: json['subject'] as String,
      currentIndex: json['current_index'] as int? ?? 0,
      correctAnswers: json['correct_answers'] as int? ?? 0,
      xpEarned: json['xp_earned'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'track_id': trackId,
        'subject': subject,
        'current_index': currentIndex,
        'correct_answers': correctAnswers,
        'xp_earned': xpEarned,
        'is_completed': isCompleted,
        'completed_at': completedAt?.toIso8601String(),
      };
}
