import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/services/api_service.dart';
import 'package:hello_world/services/connectivity_service.dart';
import 'package:hive/hive.dart';

import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final Box<Expense> _box = Hive.box<Expense>('expenses');
  final ApiService _api = ApiService();
  final ConnectivityService _connectivity = ConnectivityService();

  List<Expense> get expenses => _box.values.toList();

  StreamSubscription? _connectivitySub;

  ExpenseProvider() {
    _connectivitySub = _connectivity.connectivity$.listen((status) {
      if (status != ConnectivityResult.none) {
        syncPendingExpenses();
        pullFromServer();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
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

  bool isCategoryInUse(String categoryName) {
    return expenses.any((e) => e.category == categoryName);
  }

  Future<void> syncAll() async {
    final online = await _connectivity.isOnline();
    if (!online) {
      throw Exception("No internet connection");
    }

    // 1️⃣ Sync pending local changes
    await syncPendingExpenses();

    // 2️⃣ Pull latest from server
    await pullFromServer();
  }

  // -----------------------------
  // ADD EXPENSE (OFFLINE FIRST)
  // -----------------------------
  Future<void> addExpense(Expense expense) async {
    _box.add(expense);
    notifyListeners();

    _trySyncExpense(expense);
  }

  // -----------------------------
  // UPDATE EXPENSE
  // -----------------------------
  Future<void> updateExpense(int index, Expense expense) async {
    _box.putAt(index, expense);
    notifyListeners();

    _trySyncExpense(expense);
  }

  // -----------------------------
  // DELETE EXPENSE
  // -----------------------------
  Future<void> deleteExpense(int index) async {
    final expense = _box.getAt(index);
    if (expense == null) return;

    _box.deleteAt(index);
    notifyListeners();

    final online = await _connectivity.isOnline();
    if (online) {
      try {
        await _api.deleteExpense(expense.localId);
      } catch (_) {
        // ignore, retry strategy can be added later
      }
    }
  }

  Future<void> pullFromServer() async {
    final online = await _connectivity.isOnline();
    if (!online) return;

    try {
      final serverExpenses = await _api.fetchExpenses();

      for (final serverExpense in serverExpenses) {
        final localIndex = expenses.indexWhere(
          (e) => e.localId == serverExpense.localId,
        );

        if (localIndex == -1) {
          _box.add(serverExpense);
        } else {
          _box.putAt(localIndex, serverExpense);
        }
      }

      notifyListeners();
    } catch (_) {
      // silent fail
    }
  }

  // -----------------------------
  // SYNC ALL PENDING EXPENSES
  // -----------------------------
  Future<void> syncPendingExpenses() async {
    print('syncPendingExpenses getting called 👋');

    final online = await _connectivity.isOnline();
    if (!online) return;

    final pending = expenses.where((e) => !e.isSynced).toList();
    if (pending.isEmpty) return;

    for (final expense in pending) {
      await _trySyncExpense(expense);
    }
  }

  // -----------------------------
  // PRIVATE: TRY SYNC SINGLE EXPENSE
  // -----------------------------
  Future<void> _trySyncExpense(Expense expense) async {
    final online = await _connectivity.isOnline();
    if (!online) return;

    try {
      await _api.syncExpense(expense);
      expense.isSynced = true;
      await expense.save();
      notifyListeners();
    } catch (_) {
      // remain unsynced
    }
  }
}
