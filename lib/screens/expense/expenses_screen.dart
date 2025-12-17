import 'package:flutter/material.dart';
import 'package:hello_world/screens/expense/expense_charts_screen.dart';
import 'package:hello_world/screens/profile/profile_tab.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import 'add_edit_expense_screen.dart';

class ExpensesScreen extends StatelessWidget {
  static const routeName = '/expenses';

  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final grouped = provider.groupedByMonth;

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
      body: grouped.isEmpty
          ? const Center(child: Text("No expenses added"))
          : ListView(
              children: grouped.entries.map((entry) {
                final year = entry.key.split('-')[0];
                final month = int.parse(entry.key.split('-')[1]);

                final monthNames = [
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

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        "${monthNames[month]} $year",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...entry.value.map((expense) {
                      final index = provider.expenses.indexOf(expense);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text(expense.title),
                          subtitle: Text(
                            "${expense.category} • ${expense.date.day}/${expense.date.month}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("₹${expense.amount.toStringAsFixed(0)}"),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => provider.deleteExpense(index),
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
                    }),
                  ],
                );
              }).toList(),
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
