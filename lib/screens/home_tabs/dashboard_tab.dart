import 'package:flutter/material.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ----------------------
        // CONTAINER EXAMPLE
        // ----------------------
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.deepPurple),
          ),
          child: const Text(
            'This is a Container widget with padding, border, and background color.',
            style: TextStyle(fontSize: 16),
          ),
        ),

        const SizedBox(height: 20),

        // ----------------------
        // ROW EXAMPLE
        // ----------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Row Example',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Icon(Icons.star, color: Colors.amber.shade700),
          ],
        ),

        const SizedBox(height: 20),

        // ----------------------
        // COLUMN EXAMPLE
        // ----------------------
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Column Example Line 1', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Column Example Line 2', style: TextStyle(fontSize: 16)),
          ],
        ),

        const SizedBox(height: 20),

        // ----------------------
        // BUTTONS EXAMPLE
        // ----------------------
        const Text(
          'Buttons Example',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        ElevatedButton(onPressed: () {}, child: const Text('Elevated Button')),

        const SizedBox(height: 8),

        OutlinedButton(onPressed: () {}, child: const Text('Outlined Button')),

        const SizedBox(height: 8),

        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.thumb_up),
          color: Colors.blue,
        ),

        const SizedBox(height: 20),

        // ----------------------
        // LISTTILE EXAMPLE
        // ----------------------
        const Text(
          'ListTile Example',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('John Doe'),
            subtitle: const Text('Flutter Developer'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // You can navigate to another page here
            },
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('New Notification'),
            subtitle: const Text('You have 3 unread messages'),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
