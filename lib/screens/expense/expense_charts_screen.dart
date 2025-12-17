import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/expense_provider.dart';

class ExpenseChartsScreen extends StatelessWidget {
  final int year;
  final int month;

  const ExpenseChartsScreen({
    super.key,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final categoryData = provider.categoryTotalsForMonth(year, month);
    final dailyData = provider.dailyTotalsForMonth(year, month);

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

    return Scaffold(
      appBar: AppBar(title: Text("Charts • ${monthNames[month]} $year")),
      body: categoryData.isEmpty
          ? const Center(child: Text("No expenses for this month"))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Pie Chart
                const Text(
                  "Category Distribution",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: categoryData.entries.map((e) {
                        return PieChartSectionData(
                          title: e.key,
                          value: e.value,
                          radius: 80,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Bar Chart
                const Text(
                  "Daily Expense Trend",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      barGroups: dailyData.entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value,
                              width: 12,
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) =>
                                Text(value.toInt().toString()),
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
