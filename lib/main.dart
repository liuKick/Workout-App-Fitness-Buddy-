import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'config/supabase_config.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/services/notification_service.dart';
import 'routes/app_router.dart';
import 'core/providers/app_theme.dart';
import 'features/nutrition/providers/meal_log_provider.dart';
import 'features/workouts/providers/workout_provider.dart';
import 'features/workouts/providers/program_provider.dart';
import 'features/health/providers/health_provider.dart';
import 'features/achievements/providers/achievement_provider.dart';
import 'features/scoring/providers/scoring_provider.dart';
import 'features/achievements/widgets/achievement_popup.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  FlutterError.onError = (FlutterErrorDetails details) {
    print('🔥🔥🔥 FLUTTER ERROR: ${details.exception}');
    print('Stack: ${details.stack}');
  };
  
  PlatformDispatcher.instance.onError = (error, stack) {
    print('🔥🔥🔥 PLATFORM ERROR: $error');
    print('Stack: $stack');
    return true;
  };
  
  try {
    print('📱 Initializing Supabase...');
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    print('✅ Supabase initialized');
    
    print('📱 Initializing notifications...');
    await NotificationService().init();
    print('✅ Notifications initialized');
    
  } catch (e, stack) {
    print('🔥🔥🔥 INITIALIZATION ERROR: $e');
    print('Stack: $stack');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => MealLogProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => ProgramProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => ScoringProvider()),
        ChangeNotifierProvider(
          create: (BuildContext context) {
            final provider = AchievementProvider();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.onAchievementUnlocked = (achievement) {
                if (Navigator.canPop(context)) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => AchievementPopup(achievement: achievement),
                  ).then((_) {
                    Future.delayed(const Duration(seconds: 3), () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    });
                  });
                } else {
                  print('⚠️ Cannot show achievement popup - no navigator context');
                }
              };
            });
            return provider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 Use Consumer2 to get both ThemeProvider and SettingsProvider
    return Consumer2<ThemeProvider, SettingsProvider>(
      builder: (context, themeProvider, settingsProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fitness Buddy',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: settingsProvider.locale, // 👈 current locale from provider
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
            Locale('fr'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,          // generated delegate
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: AppRouter.welcome,
          onGenerateRoute: AppRouter.onGenerateRoute,
          builder: (context, child) {
            ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
              print('🔥🔥🔥 ROUTE ERROR: ${errorDetails.exception}');
              return Material(
                color: Colors.black,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Something went wrong',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorDetails.exception.toString(),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(context).pushReplacementNamed('/welcome');
                            }
                          },
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            };
            return child!;
          },
        );
      },
    );
  }
}