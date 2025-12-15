import 'package:flutter/material.dart';
import '../profile_tab.dart';
import 'profile_info_row.dart';

class AccountInfoCard extends StatelessWidget {
  final User user;

  const AccountInfoCard({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Account Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ProfileInfoRow(label: "Full Name", value: user.name),
            ProfileInfoRow(label: "Phone", value: user.phone),
            ProfileInfoRow(label: "Location", value: user.location),
          ],
        ),
      ),
    );
  }
}
