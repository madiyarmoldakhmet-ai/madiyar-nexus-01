import 'package:flutter/foundation.dart';
import '../models/quiz_model.dart';

/// Controls quiz sessions, XP tracking, and Madi-Credit conversion.
///
/// Conversion rate: 10 XP = 1 Madi-Credit.
class QuizController extends ChangeNotifier {
  // ── State ──
  QuizTrack? _activeTrack;
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _totalXp = 0;
  int _sessionXp = 0;
  int? _selectedOption;
  bool _hasAnswered = false;
  bool _isSessionComplete = false;

  // ── Progress tracking per subject ──
  final Map<String, QuizProgress> _progressMap = {};

  // ── Getters ──
  QuizTrack? get activeTrack => _activeTrack;
  int get currentIndex => _currentIndex;
  int get correctAnswers => _correctAnswers;
  int get totalXp => _totalXp;
  int get sessionXp => _sessionXp;
  int? get selectedOption => _selectedOption;
  bool get hasAnswered => _hasAnswered;
  bool get isSessionComplete => _isSessionComplete;
  bool get hasActiveSession => _activeTrack != null && !_isSessionComplete;

  QuizQuestion? get currentQuestion =>
      _activeTrack != null && _currentIndex < _activeTrack!.questions.length
          ? _activeTrack!.questions[_currentIndex]
          : null;

  double get progress => _activeTrack != null
      ? (_currentIndex + 1) / _activeTrack!.totalQuestions
      : 0.0;

  int get madiCreditsEarned => _totalXp ~/ 10;
  int get sessionCreditsEarned => _sessionXp ~/ 10;

  Map<String, QuizProgress> get progressMap =>
      Map.unmodifiable(_progressMap);

  /// Get progress for a specific subject.
  QuizProgress? getSubjectProgress(String subject) => _progressMap[subject];

  /// Start a new quiz session with a given track.
  void startQuiz(QuizTrack track) {
    _activeTrack = track;
    _currentIndex = 0;
    _correctAnswers = 0;
    _sessionXp = 0;
    _selectedOption = null;
    _hasAnswered = false;
    _isSessionComplete = false;
    notifyListeners();
    debugPrint('📝 Quiz started: ${track.title} (${track.totalQuestions} questions)');
  }

  /// Submit an answer for the current question.
  void submitAnswer(int optionIndex) {
    if (_hasAnswered || _activeTrack == null) return;

    _selectedOption = optionIndex;
    _hasAnswered = true;

    final question = currentQuestion!;
    if (question.isCorrect(optionIndex)) {
      _correctAnswers++;
      final xp = _activeTrack!.xpPerQuestion;
      _sessionXp += xp;
      _totalXp += xp;
      debugPrint('✅ Correct! +$xp XP');
    } else {
      debugPrint('❌ Wrong. Correct answer: ${question.correctAnswer}');
    }

    notifyListeners();
  }

  /// Move to the next question or complete the session.
  void nextQuestion() {
    if (_activeTrack == null) return;

    if (_currentIndex + 1 >= _activeTrack!.totalQuestions) {
      // Session complete!
      _isSessionComplete = true;

      // Save progress.
      _progressMap[_activeTrack!.subject] = QuizProgress(
        userId: 'current-user',
        trackId: _activeTrack!.id,
        subject: _activeTrack!.subject,
        currentIndex: _activeTrack!.totalQuestions,
        correctAnswers: _correctAnswers,
        xpEarned: _sessionXp,
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      debugPrint(
        '🎉 Quiz complete! Score: $_correctAnswers/${_activeTrack!.totalQuestions}, '
        'XP: $_sessionXp, MC earned: $sessionCreditsEarned',
      );
    } else {
      _currentIndex++;
      _selectedOption = null;
      _hasAnswered = false;
    }

    notifyListeners();
  }

  /// End the current session early.
  void endSession() {
    _activeTrack = null;
    _isSessionComplete = false;
    _selectedOption = null;
    _hasAnswered = false;
    notifyListeners();
  }

  // ────────────────────────────────────────────
  //  DEMO QUIZ DATA
  // ────────────────────────────────────────────

  static List<QuizTrack> get demoTracks => [
        QuizTrack(
          subject: 'Math',
          title: 'Algebra Fundamentals',
          description: 'Master the basics of algebraic expressions and equations.',
          difficulty: 1,
          questions: [
            QuizQuestion(
              question: 'Solve for x: 2x + 5 = 15',
              options: ['x = 3', 'x = 5', 'x = 7', 'x = 10'],
              correctIndex: 1,
              explanation: '2x + 5 = 15 → 2x = 10 → x = 5',
            ),
            QuizQuestion(
              question: 'What is the value of 3² + 4²?',
              options: ['7', '12', '25', '49'],
              correctIndex: 2,
              explanation: '3² = 9, 4² = 16, so 9 + 16 = 25',
            ),
            QuizQuestion(
              question: 'Simplify: 2(x + 3) - x',
              options: ['x + 3', 'x + 6', '2x + 3', '3x + 6'],
              correctIndex: 1,
              explanation: '2x + 6 - x = x + 6',
            ),
            QuizQuestion(
              question: 'If f(x) = x² - 1, what is f(3)?',
              options: ['4', '6', '8', '10'],
              correctIndex: 2,
              explanation: 'f(3) = 3² - 1 = 9 - 1 = 8',
            ),
            QuizQuestion(
              question: 'What is the slope of y = 3x + 7?',
              options: ['7', '3', '3x', '10'],
              correctIndex: 1,
              explanation: 'In y = mx + b, the slope m = 3',
            ),
          ],
        ),
        QuizTrack(
          subject: 'Physics',
          title: 'Newton\'s Laws',
          description: 'Understand the fundamental laws of motion.',
          difficulty: 2,
          questions: [
            QuizQuestion(
              question: 'Newton\'s First Law is also known as the Law of:',
              options: ['Acceleration', 'Inertia', 'Gravity', 'Thermodynamics'],
              correctIndex: 1,
              explanation: 'The first law states an object at rest stays at rest — this is inertia.',
            ),
            QuizQuestion(
              question: 'F = ma. If m = 5 kg and a = 3 m/s², what is F?',
              options: ['8 N', '15 N', '1.67 N', '2 N'],
              correctIndex: 1,
              explanation: 'F = 5 × 3 = 15 Newtons',
            ),
            QuizQuestion(
              question: 'What is the SI unit of force?',
              options: ['Joule', 'Watt', 'Newton', 'Pascal'],
              correctIndex: 2,
              explanation: 'Force is measured in Newtons (N).',
            ),
            QuizQuestion(
              question: 'A 10 kg object is in free fall. What is its weight? (g = 10 m/s²)',
              options: ['10 N', '100 N', '1 N', '1000 N'],
              correctIndex: 1,
              explanation: 'Weight = mg = 10 × 10 = 100 N',
            ),
            QuizQuestion(
              question: 'Newton\'s Third Law states:',
              options: [
                'F = ma',
                'Every action has an equal and opposite reaction',
                'Energy is conserved',
                'Objects at rest stay at rest'
              ],
              correctIndex: 1,
              explanation: 'For every action, there is an equal and opposite reaction.',
            ),
          ],
        ),
        QuizTrack(
          subject: 'English',
          title: 'Grammar Essentials',
          description: 'Polish your English grammar and vocabulary.',
          difficulty: 1,
          questions: [
            QuizQuestion(
              question: 'Choose the correct sentence:',
              options: [
                'Their going to the park.',
                'They\'re going to the park.',
                'There going to the park.',
                'Theyre going to the park.'
              ],
              correctIndex: 1,
              explanation: '"They\'re" is the contraction of "they are".',
            ),
            QuizQuestion(
              question: 'What is the past tense of "teach"?',
              options: ['Teached', 'Taught', 'Tought', 'Teaching'],
              correctIndex: 1,
              explanation: '"Teach" is an irregular verb. Past tense: "taught".',
            ),
            QuizQuestion(
              question: 'Which word is a synonym for "enormous"?',
              options: ['Tiny', 'Moderate', 'Gigantic', 'Average'],
              correctIndex: 2,
              explanation: '"Gigantic" means extremely large, same as "enormous".',
            ),
            QuizQuestion(
              question: '"She ___ to school every day." Choose the correct verb:',
              options: ['go', 'goes', 'going', 'gone'],
              correctIndex: 1,
              explanation: 'Third person singular present: she goes.',
            ),
            QuizQuestion(
              question: 'Identify the adverb: "She sings beautifully."',
              options: ['She', 'sings', 'beautifully', 'None'],
              correctIndex: 2,
              explanation: '"Beautifully" modifies the verb "sings" — it\'s an adverb.',
            ),
          ],
        ),
      ];
}
