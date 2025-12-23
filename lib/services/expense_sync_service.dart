import 'package:hive/hive.dart';
import '../models/expense.dart';
import 'api_service.dart';

class ExpenseSyncService {
  final Box<Expense> box = Hive.box<Expense>('expenses');
  final ApiService api;

  ExpenseSyncService(this.api);

  Future<void> syncPendingExpenses() async {
    final pending = box.values.where((e) => !e.isSynced).toList();

    if (pending.isEmpty) return;

    for (final expense in pending) {
      try {
        await api.sendExpense(expense);

        // mark as synced only after server success
        expense.isSynced = true;
        await expense.save();
      } catch (_) {
        // stop syncing on first failure
        break;
      }
    }
  }
}
