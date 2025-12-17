import 'package:flutter/material.dart';
import 'package:hello_world/screens/expense/expenses_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _loading = false;

  Future<void> _performLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    // simulate an auth request
    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', true);
    await prefs.setString('username', _usernameCtl.text.trim());

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.pushReplacementNamed(context, ExpensesScreen.routeName);
  }

  @override
  void dispose() {
    _usernameCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _usernameCtl,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter username'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtl,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter password' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _performLogin,
                      child: _loading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
