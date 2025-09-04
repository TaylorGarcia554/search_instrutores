import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_instrutores/screen/configScreen.dart';
import 'package:search_instrutores/screen/menuHome.dart';
import 'package:search_instrutores/utils/theme.dart';
// import 'package:search_instrutores/screen/home.dart';
// import 'package:search_instrutores/screen/searchPlanilha.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  // Habilita o FFI para ambientes não móveis
  sqfliteFfiInit();

  // Define o databaseFactory global
  databaseFactory = databaseFactoryFfi;

  WindowOptions windowOptions = const WindowOptions(
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    title: 'Combo Search',
    titleBarStyle: TitleBarStyle.normal,
    minimumSize: Size(900, 600),
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: MyApp()));
}


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkTheme = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'), // <- Aqui define o idioma desejado
      supportedLocales: const [
        Locale('pt', 'BR'), // Adicione o idioma desejado
      ],
      localizationsDelegates: const [
        // Adicione os delegados de localização necessários
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      // themeMode: ThemeMode.dark ,
      home: const Menuhome(),
    );
  }
}

