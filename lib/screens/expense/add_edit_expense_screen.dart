import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_world/providers/category_provider.dart';
import 'package:provider/provider.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;
  final int? index;

  const AddEditExpenseScreen({this.expense, this.index, super.key});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  DateTime selectedDate = DateTime.now();

  String? category;

  @override
  void initState() {
    super.initState();

    if (widget.expense != null) {
      titleCtrl.text = widget.expense!.title;
      amountCtrl.text = widget.expense!.amount.toString();
      category = widget.expense!.category;
      selectedDate = widget.expense!.date;
    }
  }

  void saveExpense() {
    if (!_formKey.currentState!.validate()) return;

    final expense = Expense(
      title: titleCtrl.text,
      amount: double.parse(amountCtrl.text),
      category: category!,
      date: selectedDate,
    );

    final provider = context.read<ExpenseProvider>();

    if (widget.index == null) {
      provider.addExpense(expense);
    } else {
      provider.updateExpense(widget.index!, expense);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;

    category ??= categories.isNotEmpty ? categories.first.name : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.index == null ? "Add Expense" : "Edit Expense"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) => v!.isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Amount",
                  hintText: "e.g. 250 or -50",
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^-?\d*\.?\d{0,2}$'),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter amount";
                  }

                  final parsed = double.tryParse(value);
                  if (parsed == null) {
                    return "Enter a valid number";
                  }

                  if (parsed == 0) {
                    return "Amount cannot be zero";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: category,
                items: categories
                    .map(
                      (c) =>
                          DropdownMenuItem(value: c.name, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => category = val.toString()!),
                decoration: const InputDecoration(labelText: "Category"),
              ),
              const SizedBox(height: 16),

              /// Date Picker
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: const Text("Select Date"),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: saveExpense,
                child: const Text("Save Expense"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
