import 'package:flutter/material.dart';
import 'package:hello_world/screens/profile/edit/change_password_screen.dart';
import 'package:hello_world/screens/settings/category_screen.dart';
import 'package:hello_world/screens/settings/theme_screen.dart';

class SettingsList extends StatelessWidget {
  final VoidCallback onEdit;

  const SettingsList({super.key, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Settings",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit Profile"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: onEdit, // ✔ Call the callback
              ),
              const Divider(height: 0),

              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text("Change Password"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final success = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );

                  if (success == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Password updated successfully"),
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 0),

              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text("Notification Settings"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              const Divider(height: 0),

              ListTile(
                leading: const Icon(Icons.category),
                title: const Text("Categories"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoryScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text("Theme"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ThemeScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
