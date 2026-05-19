import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:overlay_support/overlay_support.dart';
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
  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('===> [DEBUG] 🚀 App starting... WidgetsFlutterBinding initialized.');
    
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
    
    debugPrint('===> [DEBUG] Запуск runApp(NexusApp)...');
    runApp(const NexusApp());
  } catch (e, stack) {
    debugPrint("Ошибочка поймана: $e");
    debugPrint("Стек: $stack");
    runApp(const NexusApp(hasInitError: true));
  }
}

class NexusApp extends StatelessWidget {
  final bool hasInitError;
  const NexusApp({super.key, this.hasInitError = false});

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
      child: OverlaySupport.global(
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            return MaterialApp(
              title: 'Nexus',
              debugShowCheckedModeBanner: false,
              theme: MadiTheme.light,
              darkTheme: MadiTheme.dark,
              themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: hasInitError ? const LoginView() : const AuthGate(),
            );
          },
        ),
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
              context.read<ChatService>().initialize(user.id);
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
class NexusShell extends StatefulWidget {
  const NexusShell({super.key});

  @override
  State<NexusShell> createState() => _NexusShellState();
}

class _NexusShellState extends State<NexusShell> {
  static const List<Widget> _pages = [
    DiscoveryView(),
    AcademyView(),
    ChatScreen(),
    JourneyView(),
    ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    NotificationService().startListening();
  }

  @override
  void dispose() {
    NotificationService().stopListening();
    super.dispose();
  }

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
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerTheme.color ?? const Color(0xFFE4E6EB), width: 0.8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: appState.selectedTabIndex,
              onTap: appState.setTabIndex,
              backgroundColor: Colors.transparent,
              selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
              unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
              selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
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
