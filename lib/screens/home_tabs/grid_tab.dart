import 'package:flutter/material.dart';

class GridTab extends StatelessWidget {
  const GridTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: List.generate(
        6,
        (index) => Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('Item ${index + 1}'),
        ),
      ),
    );
  }
}
