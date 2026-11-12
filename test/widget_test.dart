import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendwise/main.dart';
import 'package:spendwise/models/transaction_item.dart';
import 'package:spendwise/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TransactionItem Model Tests', () {
    test('Correctly serializes and deserializes TransactionItem', () {
      final now = DateTime(2026, 11, 10, 12, 0, 0);
      final item = TransactionItem(
        id: 'tx-101',
        title: 'Coffee & Bagel',
        amount: 8.75,
        date: now,
        category: TransactionCategory.food,
        type: TransactionType.expense,
        note: 'Morning breakfast',
      );

      final jsonStr = item.toJson();
      final decoded = TransactionItem.fromJson(jsonStr);

      expect(decoded.id, item.id);
      expect(decoded.title, item.title);
      expect(decoded.amount, item.amount);
      expect(decoded.date, item.date);
      expect(decoded.category, item.category);
      expect(decoded.type, item.type);
      expect(decoded.note, item.note);
    });

    test('TransactionCategory displays correct metadata', () {
      expect(TransactionCategory.food.displayName, 'Food & Dining');
      expect(TransactionCategory.salary.displayName, 'Salary & Wages');
      expect(TransactionCategory.food.icon, Icons.restaurant);
    });
  });

  group('StorageService Persistence Tests', () {
    test('Seeds initial transactions on first launch', () async {
      SharedPreferences.setMockInitialValues({});
      final service = await StorageService.init();
      final items = await service.loadTransactions();

      expect(items.isNotEmpty, true);
      expect(items.any((item) => item.type == TransactionType.income), true);
      expect(items.any((item) => item.type == TransactionType.expense), true);
    });

    test('Saves, loads, and clears transactions correctly in SharedPreferences',
        () async {
      SharedPreferences.setMockInitialValues({
        'spendwise_seeded_v1': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final service = StorageService(prefs);

      final customTx = TransactionItem(
        id: 'test-1',
        title: 'Freelance Design',
        amount: 750.0,
        date: DateTime.now(),
        category: TransactionCategory.salary,
        type: TransactionType.income,
      );

      await service.saveTransactions([customTx]);
      final loaded = await service.loadTransactions();

      expect(loaded.length, 1);
      expect(loaded.first.title, 'Freelance Design');
      expect(loaded.first.amount, 750.0);

      await service.clearAllTransactions();
      final cleared = await service.loadTransactions();
      expect(cleared.isEmpty, true);
    });
  });

  group('SpendWise Dashboard Widget Tests', () {
    testWidgets('Renders SpendWise dashboard with summary and transactions',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final storageService = await StorageService.init();

      await tester.pumpWidget(SpendWiseApp(storageService: storageService));
      await tester.pumpAndSettle();

      expect(find.text('SpendWise'), findsOneWidget);
      expect(find.text('Total Balance'), findsOneWidget);
      expect(find.text('Add Transaction'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('100% Client-Side Local Storage (Offline Ready)'), findsOneWidget);
    });

    testWidgets('Opens add transaction dialog and allows adding transaction',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'spendwise_seeded_v1': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final storageService = StorageService(prefs);

      await tester.pumpWidget(SpendWiseApp(storageService: storageService));
      await tester.pumpAndSettle();

      // Tap floating action button to open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('New Transaction'), findsOneWidget);
      expect(find.text('Title / Description'), findsOneWidget);

      // Enter Title and Amount
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title / Description'),
        'Test Gym Membership',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Amount (₹)'),
        '55.00',
      );
      await tester.pumpAndSettle();

      // Submit
      final submitButton = find.widgetWithText(ElevatedButton, 'Add Transaction');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Dialog closed and new item visible
      expect(find.text('Test Gym Membership'), findsOneWidget);
    });
  });
}
