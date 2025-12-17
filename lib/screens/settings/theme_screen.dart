import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ThemeScreen extends StatelessWidget {
  static const routeName = '/theme';

  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Theme")),
      body: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: const Text("System Default"),
            value: ThemeMode.system,
            groupValue: provider.themeMode,
            onChanged: (mode) {
              provider.setTheme(mode!);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text("Light"),
            value: ThemeMode.light,
            groupValue: provider.themeMode,
            onChanged: (mode) {
              provider.setTheme(mode!);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text("Dark"),
            value: ThemeMode.dark,
            groupValue: provider.themeMode,
            onChanged: (mode) {
              provider.setTheme(mode!);
            },
          ),
        ],
      ),
    );
  }
}
