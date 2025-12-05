import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'dart:io' show Platform;
import 'firebase_options.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/users/users_screen.dart';
import 'presentation/screens/tax_rates/tax_rates_screen.dart';
import 'presentation/providers/auth_provider.dart';

// Import window_size conditionally to avoid web compilation issues
import 'window_size_helper.dart' if (dart.library.html) 'window_size_stub.dart' as window_helper;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up window size and properties for desktop platforms
  if (!kDebugMode && _isDesktopPlatform()) {
    _setupDesktopWindow();
  }
  
  try {
    // Initialize Firebase with platform-specific options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Log error but don't crash the app
    if (kDebugMode) {
      print('Firebase initialization error: $e');
    }
    // Re-throw to prevent app from running without Firebase
    rethrow;
  }
  
  // Run app with error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      print('Flutter Error: ${details.exception}');
    }
  };
  
  runApp(
    const ProviderScope(
      child: AroniumApp(),
    ),
  );
}

bool _isDesktopPlatform() {
  return !kDebugMode && 
    (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
}

void _setupDesktopWindow() {
  try {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      window_helper.setupWindowSize();
    }
  } catch (e) {
    // Ignore window setup errors in case we're not on desktop
    if (kDebugMode) {
      print('Window setup error: $e');
    }
  }
}

class AroniumApp extends StatelessWidget {
  const AroniumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aronium POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2A6AC8),
          primary: const Color(0xFF2A6AC8),
          secondary: const Color(0xFF3CAAD9),
          tertiary: const Color(0xFF5E35B1),
          surface: Colors.white,
          background: const Color(0xFFF8F9FA),
          error: const Color(0xFFE53935),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        // Desktop-optimized theme settings
        visualDensity: VisualDensity.standard,
        // Typography
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.w300),
          displayMedium: TextStyle(fontWeight: FontWeight.w300),
          displaySmall: TextStyle(fontWeight: FontWeight.w400),
          headlineLarge: TextStyle(fontWeight: FontWeight.w500),
          headlineMedium: TextStyle(fontWeight: FontWeight.w500),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
        // Optimize for desktop input
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2A6AC8), width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        // Optimize button sizes for mouse input
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            minimumSize: const Size(120, 48),
            backgroundColor: const Color(0xFF2A6AC8),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        // Card styling
        cardColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/users': (context) => const UsersScreen(),
        '/tax-rates': (context) => const TaxRatesScreen(),
      },
      builder: (context, child) {
        return MediaQuery(
          // Ensure text is not scaled down on web/desktop
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      // Performance optimizations
      showPerformanceOverlay: false,
      checkerboardRasterCacheImages: false,
      checkerboardOffscreenLayers: false,
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Show loading indicator while checking auth state
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authState.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
