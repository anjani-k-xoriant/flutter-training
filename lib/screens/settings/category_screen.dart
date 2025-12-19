import 'package:flutter/material.dart';
import 'package:hello_world/providers/expense_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';

class CategoryScreen extends StatelessWidget {
  static const routeName = '/categories';

  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Categories")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          final categories = provider.categories;

          if (categories.isEmpty) {
            return const Center(child: Text("No categories added"));
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (_, index) {
              final cat = categories[index];

              return ListTile(
                leading: const Icon(Icons.label),
                title: Text(cat.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showDialog(context, index, cat.name),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        final expenseProvider = context.read<ExpenseProvider>();

                        final categoryName = cat.name;

                        final canDelete = !expenseProvider.isCategoryInUse(
                          categoryName,
                        );

                        if (!canDelete) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Cannot delete "$categoryName". It is used in expenses.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Optional confirmation dialog
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Category"),
                            content: Text(
                              'Are you sure you want to delete "$categoryName"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  provider.deleteCategory(index);
                                  Navigator.pop(context);
                                },
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// ADD / EDIT dialog
  void _showDialog(BuildContext context, [int? index, String? value]) {
    final controller = TextEditingController(text: value);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(index == null ? "Add Category" : "Edit Category"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Category name"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                final provider = dialogContext.read<CategoryProvider>();

                if (index == null) {
                  provider.addCategory(name);
                } else {
                  provider.updateCategory(index, name);
                }

                Navigator.pop(dialogContext);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
