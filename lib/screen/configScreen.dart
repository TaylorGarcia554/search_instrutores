import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:search_instrutores/screen/logScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigScreen extends ConsumerStatefulWidget {
  const ConfigScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends ConsumerState<ConfigScreen> {
  bool isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tema',
                  style: TextStyle(fontSize: 18),
                ),
                Switch(
                  value: isDarkTheme,
                  activeColor: Colors.white,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).toggleTheme(value);
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 8.0,
            ),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    (MaterialPageRoute(
                      builder: (context) => LogsPage(),
                    )),
                  );
                },
                child: const Text('Acessar os Logs do Servidor',
                    style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isDarkTheme') ?? false;
  }

  Future<void> toggleTheme(bool isDark) async {
    state = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
  }
}
