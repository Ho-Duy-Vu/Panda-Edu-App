import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pandaedu/presentation/pages/home_page.dart';
import 'package:pandaedu/presentation/pages/record_page.dart';
import 'package:pandaedu/presentation/providers/flashcard_provider.dart';
import 'package:pandaedu/presentation/providers/record_stt_provider.dart';
import 'package:pandaedu/data/repositories/flashcard_repository_impl.dart';
import 'package:pandaedu/core/services/speech_service.dart';
import 'package:pandaedu/core/services/permissions_service.dart';
import 'package:pandaedu/core/theme.dart';

void main() {
  group('HomePage Widget Tests', () {
    late SharedPreferences sharedPreferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
    });

    testWidgets('should display app bar with title', (WidgetTester tester) async {
      final repository = FlashcardRepositoryImpl(sharedPreferences);
      final provider = FlashcardProvider(repository);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<FlashcardProvider>.value(
            value: provider,
            child: const HomePage(),
          ),
        ),
      );

      expect(find.text('PandaEdu'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display empty state when no flashcards', (WidgetTester tester) async {
      final repository = FlashcardRepositoryImpl(sharedPreferences);
      final provider = FlashcardProvider(repository);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<FlashcardProvider>.value(
            value: provider,
            child: const HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Chưa có flashcard'), findsOneWidget);
    });

    testWidgets('should display FAB for creating new flashcard', (WidgetTester tester) async {
      final repository = FlashcardRepositoryImpl(sharedPreferences);
      final provider = FlashcardProvider(repository);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<FlashcardProvider>.value(
            value: provider,
            child: const HomePage(),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('should navigate to RecordPage when FAB is tapped', (WidgetTester tester) async {
      final repository = FlashcardRepositoryImpl(sharedPreferences);
      final provider = FlashcardProvider(repository);
      final speechService = SpeechService();
      final permissionsService = PermissionsService();
      final recordProvider = RecordSttProvider(speechService: speechService, permissionsService: permissionsService);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FlashcardProvider>.value(value: provider),
            ChangeNotifierProvider<RecordSttProvider>.value(value: recordProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomePage(),
            onGenerateRoute: (settings) {
              if (settings.name == '/record') {
                return MaterialPageRoute(builder: (_) => const RecordPage());
              }
              return null;
            },
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should navigate to RecordPage
      expect(find.textContaining('Ghi âm'), findsOneWidget);
    });

    testWidgets('should display search icon in app bar', (WidgetTester tester) async {
      final repository = FlashcardRepositoryImpl(sharedPreferences);
      final provider = FlashcardProvider(repository);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<FlashcardProvider>.value(
            value: provider,
            child: const HomePage(),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should display menu icon in app bar', (WidgetTester tester) async {
      final repository = FlashcardRepositoryImpl(sharedPreferences);
      final provider = FlashcardProvider(repository);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<FlashcardProvider>.value(
            value: provider,
            child: const HomePage(),
          ),
        ),
      );

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
  });
}
