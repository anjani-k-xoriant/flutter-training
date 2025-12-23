import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/expense.dart';

class ApiService {
  // 🔁 Change base URL as needed
  // static const String _baseUrl = 'http://10.0.2.2:3001'; // Android emulator
  static const String _baseUrl = 'http://localhost:3001'; // Web

  Future<void> sendExpense(Expense e) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/expenses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'localId': e.localId,
        'title': e.title,
        'amount': e.amount,
        'category': e.category,
        'date': e.date.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Sync failed");
    }
  }

  Future<void> syncExpense(Expense expense) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/expenses/sync'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_expenseToJson(expense)),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to sync expense');
    }
  }

  Future<void> syncExpensesBulk(List<Expense> expenses) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/expenses/bulk-sync'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'expenses': expenses.map(_expenseToJson).toList()}),
    );

    if (response.statusCode != 200) {
      throw Exception('Bulk sync failed');
    }
  }

  Future<List<Expense>> fetchExpenses() async {
    final response = await http.get(Uri.parse('$_baseUrl/expenses'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch expenses');
    }

    final decoded = jsonDecode(response.body);
    final List data = decoded['data'];

    return data.map(_expenseFromJson).toList();
  }

  Future<void> deleteExpense(String localId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/expenses/$localId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete expense');
    }
  }

  Map<String, dynamic> _expenseToJson(Expense e) {
    return {
      'localId': e.localId,
      'title': e.title,
      'amount': e.amount,
      'category': e.category,
      'date': e.date.toIso8601String(),
    };
  }

  Expense _expenseFromJson(dynamic json) {
    return Expense(
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      date: DateTime.parse(json['date']),
      localId: json['localId'],
      isSynced: true, // Server data is always synced
    );
  }
}
