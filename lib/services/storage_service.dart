import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_item.dart';

class StorageService {
  static const String _transactionsKey = 'spendwise_transactions_v1';
  static const String _initializedKey = 'spendwise_seeded_v1';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = StorageService(prefs);
    await service._seedInitialDataIfFirstRun();
    return service;
  }

  Future<void> _seedInitialDataIfFirstRun() async {
    final hasSeeded = _prefs.getBool(_initializedKey) ?? false;
    if (!hasSeeded) {
      final now = DateTime.now();
      final initialData = [
        TransactionItem(
          id: 'seed-1',
          title: 'Monthly Salary',
          amount: 4200.00,
          date: now.subtract(const Duration(days: 3)),
          category: TransactionCategory.salary,
          type: TransactionType.income,
          note: 'Direct deposit paycheck',
        ),
        TransactionItem(
          id: 'seed-2',
          title: 'Apartment Rent',
          amount: 1450.00,
          date: now.subtract(const Duration(days: 2)),
          category: TransactionCategory.housing,
          type: TransactionType.expense,
          note: 'Monthly lease payment',
        ),
        TransactionItem(
          id: 'seed-3',
          title: 'Grocery Supermarket',
          amount: 184.50,
          date: now.subtract(const Duration(days: 1)),
          category: TransactionCategory.food,
          type: TransactionType.expense,
          note: 'Weekly essentials and fresh produce',
        ),
        TransactionItem(
          id: 'seed-4',
          title: 'Electric & Internet Bill',
          amount: 115.00,
          date: now.subtract(const Duration(hours: 18)),
          category: TransactionCategory.utilities,
          type: TransactionType.expense,
          note: 'Fiber high-speed wifi & power',
        ),
        TransactionItem(
          id: 'seed-5',
          title: 'Stock Dividend',
          amount: 135.20,
          date: now.subtract(const Duration(hours: 12)),
          category: TransactionCategory.investment,
          type: TransactionType.income,
          note: 'Quarterly index fund dividend',
        ),
        TransactionItem(
          id: 'seed-6',
          title: 'Cinema & Dinner',
          amount: 68.00,
          date: now.subtract(const Duration(hours: 5)),
          category: TransactionCategory.entertainment,
          type: TransactionType.expense,
          note: 'Weekend outing',
        ),
      ];
      await saveTransactions(initialData);
      await _prefs.setBool(_initializedKey, true);
    }
  }

  Future<List<TransactionItem>> loadTransactions() async {
    final rawJson = _prefs.getString(_transactionsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = json.decode(rawJson) as List<dynamic>;
      final list = decoded
          .map((item) => TransactionItem.fromMap(item as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveTransactions(List<TransactionItem> items) async {
    final list = items.map((e) => e.toMap()).toList();
    return await _prefs.setString(_transactionsKey, json.encode(list));
  }

  Future<bool> clearAllTransactions() async {
    return await _prefs.remove(_transactionsKey);
  }

  String exportToJson(List<TransactionItem> items) {
    final list = items.map((e) => e.toMap()).toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }

  List<TransactionItem> importFromJson(String rawJson) {
    final List<dynamic> decoded = json.decode(rawJson) as List<dynamic>;
    return decoded
        .map((item) => TransactionItem.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
