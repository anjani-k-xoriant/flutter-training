import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../providers/category_provider.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;
  final int? index;

  const AddEditExpenseScreen({super.key, this.expense, this.index});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  String? category;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    // EDIT MODE
    if (widget.expense != null) {
      titleCtrl.text = widget.expense!.title;
      amountCtrl.text = widget.expense!.amount.toString();
      category = widget.expense!.category;
      selectedDate = widget.expense!.date;
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;

    // Ensure a default category
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
              // TITLE
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Enter title" : null,
              ),

              const SizedBox(height: 12),

              // AMOUNT (numeric + negative allowed)
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

              // CATEGORY DROPDOWN
              DropdownButtonFormField<String>(
                value: category,
                items: categories
                    .map(
                      (c) =>
                          DropdownMenuItem(value: c.name, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => category = val),
                decoration: const InputDecoration(labelText: "Category"),
                validator: (v) => v == null ? "Select a category" : null,
              ),

              const SizedBox(height: 16),

              // DATE PICKER
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    style: const TextStyle(fontSize: 16),
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

              // SAVE BUTTON
              ElevatedButton(
                onPressed: _saveExpense,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ExpenseProvider>();
    final amount = double.parse(amountCtrl.text);

    // EDIT MODE
    if (widget.expense != null && widget.index != null) {
      final updatedExpense = Expense(
        title: titleCtrl.text.trim(),
        amount: amount,
        category: category!,
        date: selectedDate,

        // 🔥 Offline sync fields
        localId: widget.expense!.localId,
        isSynced: false, // needs re-sync
      );

      provider.updateExpense(widget.index!, updatedExpense);
    }
    // ADD MODE
    else {
      final newExpense = Expense(
        title: titleCtrl.text.trim(),
        amount: amount,
        category: category!,
        date: selectedDate,

        // 🔥 Offline sync fields
        localId: const Uuid().v4(),
        isSynced: false,
      );

      provider.addExpense(newExpense);
    }

    Navigator.pop(context);
  }
}
