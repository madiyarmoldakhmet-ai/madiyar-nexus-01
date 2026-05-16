import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'core/auth_service.dart';
import 'core/chat_service.dart';
import 'models/user_model.dart';
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
import 'core/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('===> [DEBUG] 🚀 App starting... WidgetsFlutterBinding initialized.');
  try {
    if (Firebase.apps.isEmpty) {
      debugPrint('===> [DEBUG] 🔥 Начинаем инициализацию Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        debugPrint('===> [DEBUG] ⚠️ Firebase initialization timed out!');
        return Firebase.app(); // Return existing app if possible
      });
      debugPrint('===> [DEBUG] 🔥 Firebase готов!');

      if (kIsWeb) {
        debugPrint("===> [DEBUG] Настройка Firestore для Web...");
        try {
          FirebaseFirestore.instance.settings = Settings(
            persistenceEnabled: true,
            // ssl and experimentalForceLongPolling are removed as they are invalid in cloud_firestore 5.6.12
          );
          debugPrint("===> [DEBUG] Firestore Web settings applied (without invalid parameters)");
        } catch (e) {
          debugPrint("===> [DEBUG] Ошибка настройки Firestore: $e");
        }
      }
    }
    
    // Initialize notifications
    debugPrint('===> [DEBUG] 🔔 Начинаем инициализацию Notifications...');
    await NotificationService().initialize();
    debugPrint('===> [DEBUG] 🔔 Notifications готовы!');
  } catch (e) {
    debugPrint('===> [DEBUG] ❌ Initialization error: $e');
  }
  
  debugPrint('===> [DEBUG] Запуск runApp(NexusApp)...');
  runApp(const NexusApp());
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

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
        title: 'Nexus',
        debugShowCheckedModeBanner: false,
        theme: MadiTheme.dark,
        darkTheme: MadiTheme.dark,
        themeMode: ThemeMode.dark,
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
    final appState = context.read<AppState>();
    
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        debugPrint('===> [DEBUG] 🛡️ AuthGate: Current state: ${authService.state}');

        // 1. Show spinner ONLY in the very initial state
        if (authService.state == AuthState.initial) {
          debugPrint('===> [DEBUG] 🛡️ AuthGate: Render Spinner (initial state)');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: MadiColors.gold),
            ),
          );
        }

        // 2. Handle Errors or Unauthenticated (redirect to Login)
        if (authService.state == AuthState.error || authService.state == AuthState.unauthenticated) {
          debugPrint('===> [DEBUG] 🛡️ AuthGate: Render LoginView (error/unauthenticated)');
          return const LoginView();
        }

        // 3. Handle Loading (e.g. during sign in process)
        if (authService.state == AuthState.loading) {
          debugPrint('===> [DEBUG] 🛡️ AuthGate: Render Spinner (loading state)');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: MadiColors.bloodRed),
            ),
          );
        }

        // 4. Authenticated state
        final user = authService.currentUser;
        if (user != null) {
          debugPrint('===> [DEBUG] 🛡️ AuthGate: User is Authenticated. Rendering NexusShell...');
          // Sync user to AppState
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (appState.currentUser != user) {
              appState.setCurrentUser(user);
            }
          });
          return const NexusShell();
        }
        
        // Fallback
        debugPrint('===> [DEBUG] 🛡️ AuthGate: Fallback. Rendering LoginView...');
        return const LoginView();
      },
    );
  }
}

/// The main shell with 5-tab bottom navigation.
class NexusShell extends StatelessWidget {
  const NexusShell({super.key});

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
          backgroundColor: Colors.transparent,
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
              backgroundColor: MadiColors.ghoulDark,
              selectedItemColor: MadiColors.bloodRed,
              unselectedItemColor: MadiColors.textMuted,
              selectedLabelStyle: GoogleFonts.oswald(fontSize: 10, fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.oswald(fontSize: 10),
              type: BottomNavigationBarType.fixed,
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
