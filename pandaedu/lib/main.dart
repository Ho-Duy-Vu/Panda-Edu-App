import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Core
import 'core/theme.dart';
import 'core/services/speech_service.dart';
import 'core/services/permissions_service.dart';

// Data
import 'data/repositories/flashcard_repository_impl.dart';
import 'data/repositories/collection_repository_impl.dart';

// Presentation
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/flashcard_provider.dart';
import 'presentation/providers/collection_provider.dart';
import 'presentation/providers/record_stt_provider.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/onboarding_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/record_page.dart';
import 'presentation/pages/confirm_transcript_page.dart';
import 'presentation/pages/detail_page.dart';
import 'presentation/pages/edit_flashcard_page.dart';
import 'presentation/pages/study_page.dart';
import 'presentation/pages/settings_page.dart';
import 'presentation/pages/collections_page.dart';

// Domain
import 'domain/entities/flashcard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    final prefs = await SharedPreferences.getInstance();
    runApp(PandaEduApp(prefs: prefs));
  } catch (e) {
    // If initialization fails, show error screen
    runApp(const ErrorApp());
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Không thể khởi động ứng dụng',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vui lòng khởi động lại ứng dụng',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PandaEduApp extends StatelessWidget {
  final SharedPreferences prefs;

  const PandaEduApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => FlashcardProvider(
            FlashcardRepositoryImpl(prefs),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CollectionProvider(
            repository: CollectionRepositoryImpl(prefs: prefs),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RecordSttProvider(
            speechService: SpeechService(),
            permissionsService: PermissionsService(),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'PandaEdu',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('vi', ''),
            ],
            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(
                    builder: (_) => const SplashPage(),
                  );
                case '/onboarding':
                  return MaterialPageRoute(
                    builder: (_) => const OnboardingPage(),
                  );
                case '/home':
                  return MaterialPageRoute(
                    builder: (_) => const HomePage(),
                  );
                case '/record':
                  return MaterialPageRoute(
                    builder: (_) => const RecordPage(),
                  );
                case '/confirm-transcript':
                  final args = settings.arguments as Map<String, dynamic>;
                  return MaterialPageRoute(
                    builder: (_) => ConfirmTranscriptPage(
                      audioPath: args['audioPath'] as String?,
                      initialTranscript: args['transcript'] as String? ?? '',
                      duration: args['duration'] as int? ?? 0,
                    ),
                  );
                case '/detail':
                  final flashcard = settings.arguments as Flashcard;
                  return MaterialPageRoute(
                    builder: (_) => DetailPage(flashcard: flashcard),
                  );
                case '/edit-flashcard':
                  final flashcard = settings.arguments as Flashcard;
                  return MaterialPageRoute(
                    builder: (_) => EditFlashcardPage(flashcard: flashcard),
                  );
                case '/study':
                  return MaterialPageRoute(
                    builder: (_) => const StudyPage(),
                  );
                case '/collections':
                  return MaterialPageRoute(
                    builder: (_) => const CollectionsPage(),
                  );
                case '/settings':
                  return MaterialPageRoute(
                    builder: (_) => const SettingsPage(),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (_) => const SplashPage(),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
