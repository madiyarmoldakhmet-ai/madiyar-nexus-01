import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'core/auth_service.dart';
import 'core/chat_service.dart';
import 'view_models/app_state.dart';
import 'view_models/credit_manager.dart';
import 'view_models/match_engine.dart';
import 'view_models/quiz_controller.dart';
import 'view_models/chat_controller.dart';
import 'view_models/ai_chat_controller.dart';
import 'views/login_view.dart';
import 'views/discovery_view.dart';
import 'views/academy_view.dart';
import 'screens/chat_screen.dart';
import 'views/journey_view.dart';
import 'views/profile_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MadibookApp());
}

class MadibookApp extends StatelessWidget {
  const MadibookApp({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AppState()..initialize()),
        ChangeNotifierProvider(create: (_) => CreditManager()),
        ChangeNotifierProvider(create: (_) => MatchEngine()),
        ChangeNotifierProvider(create: (_) => QuizController()),
        ChangeNotifierProvider(create: (_) => AiChatController()),
        ChangeNotifierProvider(create: (_) => chatService),
        ChangeNotifierProvider(
            create: (_) => ChatController(chatService)),
      ],
      child: MaterialApp(
        title: 'Madibook',
        debugShowCheckedModeBanner: false,
        theme: MadiTheme.dark,
        home: const AuthGate(),
      ),
    );
  }
}

/// Auth Gate — shows login screen or main app based on auth state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          return const MadibookShell();
        }
        return const LoginView();
      },
    );
  }
}

/// The main shell with 5-tab bottom navigation.
class MadibookShell extends StatelessWidget {
  const MadibookShell({super.key});

  static const List<Widget> _pages = [
    DiscoveryView(),
    AcademyView(),
    ChatScreen(),
    JourneyView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: IndexedStack(
            index: appState.selectedTabIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: MadiColors.surfaceDark,
              border: const Border(
                top: BorderSide(color: MadiColors.border, width: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: appState.selectedTabIndex,
              onTap: appState.setTabIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore_rounded),
                  label: 'Discover',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.school_outlined),
                  activeIcon: Icon(Icons.school_rounded),
                  label: 'Academy',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  activeIcon: Icon(Icons.chat_bubble_rounded),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.timeline_outlined),
                  activeIcon: Icon(Icons.timeline_rounded),
                  label: 'Journey',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
