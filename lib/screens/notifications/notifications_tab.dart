import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationItem {
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  // Dummy notification list
  final List<NotificationItem> notifications = [
    NotificationItem(
      title: "Welcome!",
      message: "Thank you for joining our app.",
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    NotificationItem(
      title: "New Message",
      message: "You have received a new message.",
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationItem(
      title: "Offer Alert",
      message: "New offers are available now!",
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  void markAsRead(int index) {
    setState(() {
      notifications[index].isRead = true;
    });
  }

  void markAllAsRead() {
    setState(() {
      for (var n in notifications) {
        n.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mark all read button
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: markAllAsRead,
              icon: const Icon(Icons.done_all),
              label: const Text("Mark All as Read"),
            ),
          ),
        ),

        Expanded(
          child: notifications.isEmpty
              ? const Center(
                  child: Text(
                    "No notifications",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final item = notifications[index];

                    return Card(
                      color: item.isRead
                          ? Colors.grey.shade200
                          : Colors.blue.shade50,
                      child: ListTile(
                        leading: Icon(
                          item.isRead
                              ? Icons.notifications
                              : Icons.notifications_active,
                          color: item.isRead ? Colors.grey : Colors.blue,
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: item.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.message),
                            const SizedBox(height: 4),
                            Text(
                              timeago.format(
                                item.timestamp,
                                locale: "en_short",
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: item.isRead
                            ? const Icon(Icons.check, color: Colors.green)
                            : TextButton(
                                onPressed: () => markAsRead(index),
                                child: const Text("Mark Read"),
                              ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
