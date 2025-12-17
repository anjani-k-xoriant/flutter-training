import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final Box<Expense> _box = Hive.box<Expense>('expenses');

  List<Expense> get expenses => _box.values.toList();

  void addExpense(Expense expense) {
    _box.add(expense);
    notifyListeners();
  }

  void updateExpense(int index, Expense expense) {
    _box.putAt(index, expense);
    notifyListeners();
  }

  void deleteExpense(int index) {
    _box.deleteAt(index);
    notifyListeners();
  }

  /// Month-wise grouping
  Map<String, List<Expense>> get groupedByMonth {
    final Map<String, List<Expense>> map = {};

    for (var e in expenses) {
      final key = "${e.date.year}-${e.date.month}";
      map.putIfAbsent(key, () => []);
      map[key]!.add(e);
    }

    return map;
  }

  Map<String, double> categoryTotalsForMonth(int year, int month) {
    final Map<String, double> totals = {};

    for (final e in expenses) {
      if (e.date.year == year && e.date.month == month) {
        totals[e.category] = (totals[e.category] ?? 0) + e.amount;
      }
    }
    return totals;
  }

  Map<int, double> dailyTotalsForMonth(int year, int month) {
    final Map<int, double> totals = {};

    for (final e in expenses) {
      if (e.date.year == year && e.date.month == month) {
        totals[e.date.day] = (totals[e.date.day] ?? 0) + e.amount;
      }
    }
    return totals;
  }

  /// Total of all expenses
  double get totalAmount {
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Total for a given month
  double totalForMonth(int year, int month) {
    return expenses
        .where((e) => e.date.year == year && e.date.month == month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Search by title
  List<Expense> searchExpenses(String query) {
    if (query.isEmpty) return expenses;

    return expenses
        .where((e) => e.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
