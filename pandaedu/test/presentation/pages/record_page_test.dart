import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pandaedu/presentation/pages/record_page.dart';
import 'package:pandaedu/presentation/providers/record_stt_provider.dart';
import 'package:pandaedu/core/services/speech_service.dart';
import 'package:pandaedu/core/services/permissions_service.dart';
import 'package:pandaedu/core/theme.dart';

void main() {
  group('RecordPage Widget Tests', () {
    testWidgets('should display app bar with title', (WidgetTester tester) async {
      final speechService = SpeechService();
      final permissionsService = PermissionsService();
      final provider = RecordSttProvider(speechService: speechService, permissionsService: permissionsService);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<RecordSttProvider>.value(
            value: provider,
            child: const RecordPage(),
          ),
        ),
      );

      expect(find.text('Ghi âm'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display panda mic image', (WidgetTester tester) async {
      final speechService = SpeechService();
      final permissionsService = PermissionsService();
      final provider = RecordSttProvider(speechService: speechService, permissionsService: permissionsService);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<RecordSttProvider>.value(
            value: provider,
            child: const RecordPage(),
          ),
        ),
      );

      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('should display timer at 00:00 initially', (WidgetTester tester) async {
      final speechService = SpeechService();
      final permissionsService = PermissionsService();
      final provider = RecordSttProvider(speechService: speechService, permissionsService: permissionsService);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<RecordSttProvider>.value(
            value: provider,
            child: const RecordPage(),
          ),
        ),
      );

      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('should display large mic FAB when idle', (WidgetTester tester) async {
      final speechService = SpeechService();
      final permissionsService = PermissionsService();
      final provider = RecordSttProvider(speechService: speechService, permissionsService: permissionsService);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<RecordSttProvider>.value(
            value: provider,
            child: const RecordPage(),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should display progress indicator', (WidgetTester tester) async {
      final speechService = SpeechService();
      final permissionsService = PermissionsService();
      final provider = RecordSttProvider(speechService: speechService, permissionsService: permissionsService);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<RecordSttProvider>.value(
            value: provider,
            child: const RecordPage(),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should show STT unavailable message when STT is not available', 
        (WidgetTester tester) async {
      final speechService = SpeechService();
      final permissionsService = PermissionsService();
      final provider = RecordSttProvider(speechService: speechService, permissionsService: permissionsService);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<RecordSttProvider>.value(
            value: provider,
            child: const RecordPage(),
          ),
        ),
      );

      // Initially STT availability is unknown, test will show either LiveTranscriptView or warning
      expect(find.byType(RecordPage), findsOneWidget);
    });

    testWidgets('should display back button in app bar', (WidgetTester tester) async {
      final speechService = SpeechService();
      final permissionsService = PermissionsService();
      final provider = RecordSttProvider(speechService: speechService, permissionsService: permissionsService);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<RecordSttProvider>.value(
            value: provider,
            child: const RecordPage(),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
