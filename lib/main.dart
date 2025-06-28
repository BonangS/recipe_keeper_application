import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'screens/get_started_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Mengatur aplikasi menjadi fullscreen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  
  await Supabase.initialize(
    url: 'https://swzeqzborrvagqlahshg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN3emVxemJvcnJ2YWdxbGFoc2hnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4Mjc0NzksImV4cCI6MjA2NjQwMzQ3OX0.SeIo9JzDqB21CFRMEHolkFLty7g2qGZH3vGqAb3HuTk',
  );
  final prefs = await SharedPreferences.getInstance();
  runApp(AppEntry(prefs: prefs));
}

class AppEntry extends StatefulWidget {
  final SharedPreferences prefs;
  const AppEntry({required this.prefs, super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  late bool hasSeenGetStarted;

  @override
  void initState() {
    super.initState();
    hasSeenGetStarted = widget.prefs.getBool('hasSeenGetStarted') ?? false;
  }

  void updateHasSeen() {
    setState(() {
      hasSeenGetStarted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyApp(
      hasSeenGetStarted: hasSeenGetStarted,
      prefs: widget.prefs,
      onGetStarted: updateHasSeen,
    );
  }
}

class MyApp extends StatelessWidget {
  final bool hasSeenGetStarted;
  final SharedPreferences prefs;
  final VoidCallback? onGetStarted;

  const MyApp({
    required this.hasSeenGetStarted,
    required this.prefs,
    this.onGetStarted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => AuthService(prefs),
        ),
        ChangeNotifierProxyProvider<AuthService, AuthProvider>(
          create: (context) => AuthProvider(
            Provider.of<AuthService>(context, listen: false),
          ),
          update: (context, authService, previous) =>
              previous ?? AuthProvider(authService),
        ),
      ],
      builder: (context, child) {
        final authProvider = context.watch<AuthProvider>();
        final isLoggedIn = authProvider.isLoggedIn;

        final router = GoRouter(
          initialLocation: hasSeenGetStarted ? '/login' : '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => GetStartedScreen(onGetStarted: onGetStarted),
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) => const LoginScreen(),
            ),
            ShellRoute(
              builder: (context, state, child) {
                return child; // Tanpa navigation bar
              },
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
          ],
          redirect: (context, state) {
            final isLoggingIn = state.uri.toString() == '/login';
            final isGettingStarted = state.uri.toString() == '/';

            if (!hasSeenGetStarted && !isGettingStarted) {
              return '/';
            }

            if (isLoggedIn && (isLoggingIn || isGettingStarted)) {
              return '/home';
            }

            if (!isLoggedIn && !isLoggingIn && !isGettingStarted) {
              return '/login';
            }

            return null;
          },
        );

        return MaterialApp.router(
          title: 'Recipe Keeper',
          theme: ThemeData(
            primarySwatch: Colors.orange,
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              ),
              backgroundColor: Colors.orange.shade800,
              elevation: 0,
              foregroundColor: Colors.white,
            ),
          ),
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        );
      },
    );
  }
}
