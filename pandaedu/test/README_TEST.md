# PandaEdu Test Suite 🧪

Comprehensive test suite for the PandaEdu Flutter application covering unit tests, widget tests, and integration tests.

## Test Structure

```
test/
├── core/                           # Core functionality tests
│   └── constants_test.dart         # Validators and constants
├── domain/
│   ├── entities/
│   │   └── flashcard_test.dart     # Entity and model tests
│   └── usecases/
│       └── flashcard_usecases_test.dart  # Business logic tests
├── data/
│   └── repositories/
│       └── flashcard_repository_impl_test.dart  # Repository tests
├── presentation/
│   ├── widgets/
│   │   ├── flashcard_tile_test.dart      # Widget tests
│   │   └── panda_empty_state_test.dart   # Widget tests
│   └── pages/
│       ├── home_page_test.dart           # Page tests
│       └── record_page_test.dart         # Page tests
└── integration/
    └── app_integration_test.dart         # End-to-end tests
```

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/domain/entities/flashcard_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Run Integration Tests Only
```bash
flutter test test/integration/
```

## Test Coverage

### Core Tests (constants_test.dart)
- ✅ FlashcardValidator validation logic
- ✅ AppColors definitions
- ✅ AppSizes constants
- ✅ StorageKeys constants

### Domain Tests

#### Flashcard Entity (flashcard_test.dart)
- ✅ Entity creation with required fields
- ✅ Entity creation with all fields
- ✅ Equality comparison
- ✅ FlashcardModel JSON serialization
- ✅ FlashcardModel JSON deserialization
- ✅ Entity to Model conversion
- ✅ Roundtrip serialization

#### UseCases (flashcard_usecases_test.dart)
- ✅ CreateFlashcard
- ✅ GetAllFlashcards
- ✅ UpdateFlashcard
- ✅ DeleteFlashcard
- ✅ GetDueFlashcards

### Data Tests

#### Repository (flashcard_repository_impl_test.dart)
- ✅ Get all flashcards (empty state)
- ✅ Create flashcard
- ✅ Update flashcard
- ✅ Delete flashcard
- ✅ Get flashcard by ID
- ✅ Get due flashcards
- ✅ Search flashcards by title
- ✅ Search flashcards by transcript
- ✅ Handle multiple flashcards without type error
- ✅ Serialization/deserialization integrity

### Presentation Tests

#### Widgets
- **FlashcardTile** (flashcard_tile_test.dart)
  - ✅ Display title and transcript
  - ✅ Show panda placeholder image
  - ✅ Handle tap events
  - ✅ Show play icon when audio exists
  - ✅ Hide play icon when no audio
  - ✅ Format date correctly

- **PandaEmptyState** (panda_empty_state_test.dart)
  - ✅ Display message and image
  - ✅ Default message handling
  - ✅ Centered layout

#### Pages
- **HomePage** (home_page_test.dart)
  - ✅ Display app bar with title
  - ✅ Display empty state when no flashcards
  - ✅ Display FAB for creating flashcard
  - ✅ Navigate to RecordPage on FAB tap
  - ✅ Display search icon
  - ✅ Display menu icon

- **RecordPage** (record_page_test.dart)
  - ✅ Display app bar with title
  - ✅ Display panda mic image
  - ✅ Display timer at 00:00 initially
  - ✅ Display large mic FAB when idle
  - ✅ Display progress indicator
  - ✅ Show STT unavailable message
  - ✅ Display back button

### Integration Tests (app_integration_test.dart)
- ✅ Complete app flow: onboarding → create → view → delete
- ✅ Settings navigation and theme toggle
- ✅ Empty state verification
- ✅ Navigation between all main screens
- ✅ Provider CRUD operations
- ✅ Search and filter functionality
- ✅ Sort functionality

## Test Fixtures

### Mock Data
Tests use SharedPreferences mock with `SharedPreferences.setMockInitialValues({})`.

### Sample Flashcard
```dart
final testFlashcard = Flashcard(
  id: 'test-id-1',
  title: 'Test Flashcard',
  transcript: 'Test transcript content',
  audioPath: null,
  createdAt: DateTime(2025, 12, 10),
  duration: 5,
);
```

## Known Issues and Limitations

### Mocking Limitations
- Speech-to-text service cannot be fully tested without device
- Audio recording requires platform channels (not testable in unit tests)
- Permission requests require integration tests on real devices

### Coverage Goals
- **Target:** 80%+ code coverage
- **Current Focus:** Core business logic and data layer
- **Future:** Add golden tests for UI consistency

## Writing New Tests

### Widget Test Template
```dart
testWidgets('should do something', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: YourWidget(),
    ),
  );

  expect(find.text('Expected Text'), findsOneWidget);
});
```

### Unit Test Template
```dart
test('should perform action', () {
  // Arrange
  final input = 'test';
  
  // Act
  final result = functionUnderTest(input);
  
  // Assert
  expect(result, expectedValue);
});
```

## CI/CD Integration

Add to your GitHub Actions workflow:
```yaml
- name: Run tests
  run: flutter test --coverage

- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    files: coverage/lcov.info
```

## Best Practices

1. **Arrange-Act-Assert** pattern for clarity
2. **Descriptive test names** that explain what is being tested
3. **Mock external dependencies** to isolate units
4. **Use setUp and tearDown** for common initialization
5. **Test edge cases** and error conditions
6. **Keep tests fast** - avoid unnecessary delays

## Troubleshooting

### Tests Fail with "No Material widget found"
Wrap your widget in `MaterialApp`:
```dart
await tester.pumpWidget(MaterialApp(home: YourWidget()));
```

### Tests Timeout
Increase timeout or check for infinite loops:
```dart
testWidgets('test', (tester) async {
  // ...
}, timeout: Timeout(Duration(seconds: 30)));
```

### SharedPreferences Error
Always initialize mock before tests:
```dart
setUp(() async {
  SharedPreferences.setMockInitialValues({});
  sharedPreferences = await SharedPreferences.getInstance();
});
```

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/cookbook/testing/integration/introduction)
- [Mockito Package](https://pub.dev/packages/mockito)
