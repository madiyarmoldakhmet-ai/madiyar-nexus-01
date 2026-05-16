import 'dart:async';


/// Represents a single AI chat message.
class AiMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  AiMessage({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Mock AI Chat Service that simulates an LLM-powered mentor.
///
/// To connect to a real API, replace [_generateResponse] with:
///   - OpenAI: POST https://api.openai.com/v1/chat/completions
///   - Gemini: POST https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent
///
/// The service is fully decoupled from the UI — swap the implementation
/// without touching any view code.
class AiChatService {
  // Set your API key here when ready for production.
  // static const String _apiKey = 'YOUR_API_KEY';
  // static const String _model = 'gpt-4o-mini'; // or 'gemini-pro'


  /// Generate a response from the AI mentor.
  ///
  /// In production, replace this with an HTTP call to OpenAI/Gemini.
  Future<String> generateResponse(String userMessage, List<AiMessage> history) async {
    // Simulate network latency.
    await Future.delayed(const Duration(milliseconds: 1200));

    final lowerMsg = userMessage.toLowerCase();

    // ── Math responses ──
    if (_matchesAny(lowerMsg, ['math', 'algebra', 'equation', 'calculus', 'solve', 'formula'])) {
      return _pickRandom([
        "Great math question! 📐 Let me break this down step by step.\n\n"
            "The key to solving equations is to isolate the variable. "
            "Remember: whatever you do to one side, do to the other.\n\n"
            "Want me to walk through a specific problem? You'll earn XP in the Academy too!",
        "Math is just patterns once you see them! 🧮\n\n"
            "Here's my approach: start with what you know, identify what you need to find, "
            "and build a bridge between them using the rules you've learned.\n\n"
            "Try the Algebra quiz in the Academy — every correct answer earns you 10 XP → 1 Nexus-Credit!",
        "I love math questions! Think of equations like a balance scale ⚖️\n\n"
            "Both sides must always be equal. To find the unknown, "
            "use inverse operations to 'undo' what's been done to the variable.\n\n"
            "What specific topic are you working on? I can give you a targeted explanation.",
      ]);
    }

    // ── Physics responses ──
    if (_matchesAny(lowerMsg, ['physics', 'newton', 'force', 'gravity', 'motion', 'energy'])) {
      return _pickRandom([
        "Physics is how the universe works! 🌌\n\n"
            "Newton's laws are the foundation: an object at rest stays at rest (inertia), "
            "F = ma connects force to acceleration, and every action has an equal reaction.\n\n"
            "The Newton's Laws quiz in the Academy will test your understanding. Ready to earn some XP?",
        "Great physics question! 🔬\n\n"
            "The trick with physics is to draw it out. Free body diagrams are your best friend — "
            "sketch the object, draw all the forces, and then apply F = ma.\n\n"
            "Would you like me to work through a specific problem with you?",
        "Physics makes the invisible visible! ⚡\n\n"
            "Energy is always conserved — it just changes form. Kinetic ↔ Potential ↔ Thermal. "
            "This is one of the most powerful ideas in all of science.\n\n"
            "Check out the Physics track in the Academy to level up your skills!",
      ]);
    }

    // ── English responses ──
    if (_matchesAny(lowerMsg, ['english', 'grammar', 'vocabulary', 'tense', 'verb', 'sentence', 'word'])) {
      return _pickRandom([
        "English practice time! 📝\n\n"
            "The key to good grammar is understanding the structure: Subject + Verb + Object. "
            "Master this pattern and everything else builds on top of it.\n\n"
            "The Grammar Essentials quiz in the Academy is a great place to practice!",
        "Let's work on your English! 🗣️\n\n"
            "Reading is the fastest way to improve vocabulary. Try reading one article per day "
            "and write down 3 new words. In a month, that's 90 new words!\n\n"
            "What specific area would you like to focus on — grammar, vocabulary, or writing?",
      ]);
    }

    // ── FPV / Drones ──
    if (_matchesAny(lowerMsg, ['fpv', 'drone', 'flying', 'quad', 'pilot', 'betaflight'])) {
      return _pickRandom([
        "FPV is the ultimate combination of engineering and art! 🚁\n\n"
            "Building your first quad teaches you electronics (ESCs, flight controllers), "
            "software (Betaflight config), and physics (thrust-to-weight ratio) all at once.\n\n"
            "Madiyar started with FPV racing — it's in Nexus's DNA! Check the Journey tab for his story.",
        "FPV flying is addictive! 🏎️💨\n\n"
            "Start with a simulator (Liftoff or Velocidrone) before flying real quads. "
            "You'll save hundreds of dollars in crashed parts. Trust me.\n\n"
            "Once you're comfortable, the real world feels like a video game. Pure freedom!",
      ]);
    }

    // ── Robotics ──
    if (_matchesAny(lowerMsg, ['robot', 'arduino', 'raspberry', 'ros', 'sensor', 'autonomous'])) {
      return "Robotics is where software meets the real world! 🤖\n\n"
          "Start with Arduino for basics, then graduate to ROS for serious autonomy. "
          "Madiyar won a robotics competition with a line-following bot — check the Journey tab!\n\n"
          "What kind of robot are you building? I can help with the architecture.";
    }

    // ── Nexus-Credits ──
    if (_matchesAny(lowerMsg, ['credit', 'nexus-credit', 'earn', 'points', 'xp'])) {
      return "Nexus-Credits are the heart of Nexus! 💰\n\n"
          "Here's how to earn them:\n"
          "• **Teach someone** for 1 hour → earn 1 NC\n"
          "• **Complete quizzes** in the Academy → 10 XP = 1 NC\n"
          "• **Help in chat** → build your reputation for more swap requests\n\n"
          "The more you give, the more you can learn. That's the Nexus way! 🌍";
    }

    // ── Greetings ──
    if (_matchesAny(lowerMsg, ['hello', 'hi', 'hey', 'salam', 'salem', 'privet'])) {
      return "Hey there! 👋 I'm Madi Mentor, your AI learning companion.\n\n"
          "I can help you with:\n"
          "• 📐 **Math** — Algebra, Calculus, and more\n"
          "• 🔬 **Physics** — Newton's Laws, Energy, Motion\n"
          "• 📝 **English** — Grammar, Vocabulary, Writing\n"
          "• 🚁 **FPV Drones** — Building, Flying, Betaflight\n"
          "• 🤖 **Robotics** — Arduino, ROS, Sensors\n\n"
          "What would you like to learn today?";
    }

    // ── Default response ──
    return _pickRandom([
      "That's an interesting question! 🤔\n\n"
          "I'm best at Math, Physics, English, FPV drones, and Robotics. "
          "Could you rephrase your question in one of those areas?\n\n"
          "Or head to the Academy tab to start earning XP right away!",
      "I'm always learning too! 📚\n\n"
          "While I think about that, why not check out the Academy? "
          "You can earn Nexus-Credits while studying Math, Physics, or English.\n\n"
          "Ask me anything about those subjects and I'll give you a detailed explanation!",
    ]);
  }

  bool _matchesAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  String _pickRandom(List<String> options) {
    return options[DateTime.now().millisecond % options.length];
  }
}
