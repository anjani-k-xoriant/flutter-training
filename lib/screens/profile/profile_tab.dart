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
  static const routeName = '/profile';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Failed to load profile"),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: refreshData,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

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
                    final updated = await Navigator.of(context).push<User>(
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(user: user),
                      ),
                    );

                    if (updated != null) {
                      setState(() {
                        _userFuture = Future.value(updated);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                LogoutButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logout pressed')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
