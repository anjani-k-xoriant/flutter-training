import 'package:flutter/material.dart';
import 'package:hello_world/models/category.dart';
import 'package:hello_world/models/expense.dart';
import 'package:hello_world/providers/auth_provider.dart';
import 'package:hello_world/providers/category_provider.dart';
import 'package:hello_world/providers/expense_provider.dart';
import 'package:hello_world/providers/theme_provider.dart';
import 'package:hello_world/providers/user_provider.dart';
import 'package:hello_world/screens/profile/profile_tab.dart';
import 'package:hello_world/screens/settings/category_screen.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'screens/expense/expenses_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(CategoryAdapter());
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox<Category>('categories');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CategoryProvider()..addDefaultsIfEmpty(),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Expe Screen Demo',
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        '/home': (_) => const ExpensesScreen(),
        '/categories': (_) => const CategoryScreen(),
        ExpensesScreen.routeName: (_) => const ExpensesScreen(),
        ProfileTab.routeName: (_) => const ProfileTab(),
      },
    );
  }
}
