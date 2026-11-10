import 'dart:convert';
import 'package:flutter/material.dart';

enum TransactionType {
  expense,
  income,
}

enum TransactionCategory {
  food,
  transportation,
  housing,
  utilities,
  entertainment,
  health,
  shopping,
  education,
  salary,
  investment,
  other;

  String get displayName {
    switch (this) {
      case TransactionCategory.food:
        return 'Food & Dining';
      case TransactionCategory.transportation:
        return 'Transportation';
      case TransactionCategory.housing:
        return 'Housing & Rent';
      case TransactionCategory.utilities:
        return 'Utilities & Bills';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.health:
        return 'Health & Fitness';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.education:
        return 'Education';
      case TransactionCategory.salary:
        return 'Salary & Wages';
      case TransactionCategory.investment:
        return 'Investments';
      case TransactionCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.transportation:
        return Icons.directions_car;
      case TransactionCategory.housing:
        return Icons.home;
      case TransactionCategory.utilities:
        return Icons.electric_bolt;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.health:
        return Icons.fitness_center;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.education:
        return Icons.school;
      case TransactionCategory.salary:
        return Icons.payments;
      case TransactionCategory.investment:
        return Icons.trending_up;
      case TransactionCategory.other:
        return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case TransactionCategory.food:
        return const Color(0xFFF97316); // Orange
      case TransactionCategory.transportation:
        return const Color(0xFF0EA5E9); // Sky
      case TransactionCategory.housing:
        return const Color(0xFF6366F1); // Indigo
      case TransactionCategory.utilities:
        return const Color(0xFFEAB308); // Yellow
      case TransactionCategory.entertainment:
        return const Color(0xFFA855F7); // Purple
      case TransactionCategory.health:
        return const Color(0xFFEC4899); // Pink
      case TransactionCategory.shopping:
        return const Color(0xFF14B8A6); // Teal
      case TransactionCategory.education:
        return const Color(0xFF3B82F6); // Blue
      case TransactionCategory.salary:
        return const Color(0xFF10B981); // Emerald
      case TransactionCategory.investment:
        return const Color(0xFF059669); // Dark emerald
      case TransactionCategory.other:
        return const Color(0xFF64748B); // Slate
    }
  }
}

class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionCategory category;
  final TransactionType type;
  final String note;

  const TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.note = '',
  });

  TransactionItem copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    TransactionCategory? category,
    TransactionType? type,
    String? note,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.name,
      'type': type.name,
      'note': note,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      category: TransactionCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => TransactionCategory.other,
      ),
      type: TransactionType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      note: (map['note'] as String?) ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionItem.fromJson(String source) =>
      TransactionItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

