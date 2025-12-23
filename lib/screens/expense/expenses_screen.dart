import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/screens/expense/expense_charts_screen.dart';
import 'package:hello_world/screens/profile/profile_tab.dart';
import 'package:hello_world/services/api_service.dart';
import 'package:hello_world/services/connectivity_service.dart';
import 'package:provider/provider.dart';

import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import 'add_edit_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  static const routeName = '/expenses';

  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _searchQuery = '';
  late final ConnectivityService _connectivityService;

  bool _isSyncing = false;

  static const List<String> _monthNames = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  IconData _getExpenseIcon(double amount) {
    return amount < 0
        ? Icons
              .arrow_upward // Cashback
        : Icons.arrow_downward; // Expense
  }

  Color _getExpenseColor(BuildContext context, double amount) {
    return amount < 0 ? Colors.green : Theme.of(context).colorScheme.error;
  }

  String _formatAmount(double amount) {
    return "₹${amount.abs().toStringAsFixed(0)}";
  }

  Future<void> _syncExpenses() async {
    if (_isSyncing) return;

    final online = await _connectivityService.isOnline();
    if (!online) return;

    setState(() => _isSyncing = true);

    try {
      final provider = context.read<ExpenseProvider>(); // ✅ FIX
      await provider.syncAll();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Expenses synced successfully")),
        );
      }
    } catch (_) {
      // silently fail – retry later
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService();

  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final now = DateTime.now();

    final searchedExpenses = provider.searchExpenses(_searchQuery);

    // 📅 Group searched expenses month-wise
    final Map<String, List<Expense>> grouped = {};
    for (final e in searchedExpenses) {
      final key = "${e.date.year}-${e.date.month}";
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(e);
    }

    double _calculateMonthTotal(List<Expense> expenses) {
      return expenses.fold(0.0, (sum, e) => sum + e.amount);
    }

    // 💰 Monthly total (current month)
    final monthlyTotal = provider.totalForMonth(now.year, now.month);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses"),
        actions: [
          IconButton(
				icon: const Icon(Icons.bar_chart),
				tooltip: "View Charts",
				onPressed: () async {
				  // Default: current month
				  final now = DateTime.now();

				  // Optional: show month picker dialog
				  final selected = await showMonthPicker(context, now);

				  if (selected == null) return;

				  Navigator.push(
					context,
					MaterialPageRoute(
					  builder: (_) => ExpenseChartsScreen(
						year: selected.year,
						month: selected.month,
					  ),
					),
				  );
				},
			  ),
			  IconButton(
				icon: const Icon(Icons.person),
				tooltip: "Profile",
				onPressed: () {
				  Navigator.pushNamed(context, ProfileTab.routeName);
				},
			  ),
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.cloud_sync),
              tooltip: "Sync now",
              onPressed: _syncExpenses,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by expense name",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // 💰 Monthly Total Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              elevation: 2,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                title: const Text(
                  "Total This Month",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  "₹${monthlyTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 📋 Expense List
          Expanded(
            child: grouped.isEmpty
                ? const Center(
                    child: Text(
                      "No expenses found",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView(
                    children: grouped.entries.map((entry) {
                      final year = int.parse(entry.key.split('-')[0]);
                      final month = int.parse(entry.key.split('-')[1]);
                      final monthTotal = _calculateMonthTotal(entry.value);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 📅 Month Header
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${_monthNames[month]} $year",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "₹${monthTotal.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 🧾 Expenses for the month
                          ...entry.value.map((expense) {
                            final index = provider.expenses.indexOf(expense);

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: SizedBox(
                                  width: 48,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _getExpenseIcon(expense.amount),
                                        color: _getExpenseColor(
                                          context,
                                          expense.amount,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Icon(
                                        expense.isSynced
                                            ? Icons.cloud_done
                                            : Icons.cloud_off,
                                        size: 14,
                                        color: expense.isSynced
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ],
                                  ),
                                ),

                                title: Text(expense.title),
                                subtitle: Text(
                                  "${expense.category} • "
                                  "${expense.date.day}/${expense.date.month}/${expense.date.year}",
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "₹${expense.amount.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        provider.deleteExpense(index);
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddEditExpenseScreen(
                                        expense: expense,
                                        index: index,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> showMonthPicker(
    BuildContext context,
    DateTime initial,
  ) async {
    int selectedYear = initial.year;
    int selectedMonth = initial.month;

    return showDialog<DateTime>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Month"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Year Dropdown
              DropdownButton<int>(
                value: selectedYear,
                items: List.generate(5, (i) {
                  final year = DateTime.now().year - i;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                onChanged: (val) {
                  if (val != null) {
                    selectedYear = val;
                  }
                },
              ),

              const SizedBox(height: 12),

              // Month Grid
              Wrap(
                spacing: 8,
                children: List.generate(12, (index) {
                  final month = index + 1;
                  return ChoiceChip(
                    label: Text(
                      [
                        "Jan",
                        "Feb",
                        "Mar",
                        "Apr",
                        "May",
                        "Jun",
                        "Jul",
                        "Aug",
                        "Sep",
                        "Oct",
                        "Nov",
                        "Dec",
                      ][index],
                    ),
                    selected: selectedMonth == month,
                    onSelected: (_) {
                      selectedMonth = month;
                    },
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, DateTime(selectedYear, selectedMonth));
              },
              child: const Text("View"),
            ),
          ],
        );
      },
    );
  }
}
