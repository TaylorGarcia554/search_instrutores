import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/components/theme.dart';
import 'package:search_instrutores/screen/home.dart';
import 'package:search_instrutores/screen/searchPlanilha.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  // Habilita o FFI para ambientes não móveis
  sqfliteFfiInit();

  // Define o databaseFactory global
  databaseFactory = databaseFactoryFfi;

  WindowOptions windowOptions = WindowOptions(
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    title: 'Combo Search',
    titleBarStyle: TitleBarStyle.normal,
    minimumSize: const Size(900, 600),
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(ProviderScope(child: MyApp()));
}

final themeProvider = StateProvider<bool>((ref) => false);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      // themeMode: ThemeMode.dark ,
      home: Home(),
    );
  }
}

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // return BuscaPlanilhaPage();
    return HomeScreen();
  }
}
