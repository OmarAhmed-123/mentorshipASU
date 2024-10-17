import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart'; // For creating mock services

import 'package:task1_in_sqflite_and_hive/main.dart';
import 'package:task1_in_sqflite_and_hive/services/api_service.dart';
import 'package:task1_in_sqflite_and_hive/services/database_service.dart';

// Create mock classes for ApiService and DatabaseService
class MockApiService extends Mock implements ApiService {}

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Create mock instances of the services
    final mockApiService = MockApiService();
    final mockDatabaseService = MockDatabaseService();

    // Build the app with mock services and trigger a frame.
    await tester.pumpWidget(MyApp(
      apiService: mockApiService,
      databaseService: mockDatabaseService,
    ));

    // Verify that the counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that the counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
