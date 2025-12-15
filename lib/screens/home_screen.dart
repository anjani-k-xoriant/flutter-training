import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'splash_screen.dart';

// Import tabs
import 'home_tabs/dashboard_tab.dart';
import 'home_tabs/grid_tab.dart';
import 'search/search_tab.dart';
import 'notifications/notifications_tab.dart';
import 'profile/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;
  String? _username;
  int _selectedIndex = 0;

  // Public GlobalKey for ProfileTab's public state class
  final GlobalKey<ProfileTabState> profileKey = GlobalKey<ProfileTabState>();

  // non-const list because one entry (ProfileTab) needs the runtime key
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();

    // initialize pages here so profileKey is available
    _pages.addAll([
      const DashboardTab(),
      const GridTab(),
      const SearchTab(),
      const NotificationsTab(),
      ProfileTab(key: profileKey), // <-- non-const, uses runtime key
    ]);

    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', false);
    await prefs.remove('username');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  void _incrementCounter() => setState(() => _counter++);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // if profile tab selected, trigger refresh
    // profile is last index in the list
    final int profileIndex = _pages.length - 1;
    if (index == profileIndex) {
      profileKey.currentState?.refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home - ${_username ?? ''}'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Grid'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
