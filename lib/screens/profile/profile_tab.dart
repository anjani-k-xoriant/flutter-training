import 'package:flutter/material.dart';
import 'widgets/profile_header.dart';
import 'widgets/account_info_card.dart';
import 'widgets/settings_list.dart';
import 'widgets/logout_button.dart';
import 'edit/edit_profile_screen.dart';

/// Simple user model for the dummy data
class User {
  final String name;
  final String email;
  final String phone;
  final String location;

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
  });
}

/// Simulate fetching user data from network / storage
Future<User> fetchDummyUserData() async {
  await Future.delayed(const Duration(seconds: 2));
  return User(
    name: 'John Doe',
    email: 'john.doe@example.com',
    phone: '+91 9876543210',
    location: 'India',
  );
}

/// Main ProfileTab widget (State is public so HomeScreen can call refreshData())
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  ProfileTabState createState() => ProfileTabState();
}

class ProfileTabState extends State<ProfileTab> {
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = fetchDummyUserData();
  }

  /// Called from HomeScreen via GlobalKey to force reload
  Future<void> refreshData() async {
    setState(() {
      _userFuture = fetchDummyUserData();
    });
    await _userFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Failed to load user data.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: refreshData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Data
        final user = snapshot.data!;
        return RefreshIndicator(
          onRefresh: refreshData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              ProfileHeader(name: user.name, email: user.email),
              const SizedBox(height: 16),
              AccountInfoCard(user: user),
              const SizedBox(height: 20),
              SettingsList(
                onEdit: () async {
                  // push the edit screen and wait for result
                  final updated = await Navigator.of(context).push<User>(
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(user: user),
                    ),
                  );

                  if (updated != null) {
                    // Update the UI immediately with the returned user
                    setState(() {
                      _userFuture = Future.value(updated);
                    });

                    // OPTIONAL: persist to prefs or backend
                    // await saveUserToPrefs(updated);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated')),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              LogoutButton(
                onPressed: () {
                  // You can implement logout logic here or pass a callback from HomeScreen.
                  // For demo, show snackbar:
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logout pressed')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
