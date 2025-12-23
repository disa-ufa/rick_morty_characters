import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/settings/settings_store.dart';
import '../features/characters/characters_screen.dart';
import '../features/favorites/favorites_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _index = 0;

  // чтобы при переключении вкладок они НЕ пересоздавались.
  late final List<Widget> _pages = const [
    CharactersScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsStore>();

    final light = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      useMaterial3: true,
    );

    final dark = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: light,
      darkTheme: dark,
      themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Rick & Morty'),
          actions: [
            IconButton(
              tooltip: 'Тема',
              onPressed: settings.toggleTheme,
              icon: Icon(settings.isDark ? Icons.dark_mode : Icons.light_mode),
            ),
          ],
        ),

        body: IndexedStack(
          index: _index,
          children: _pages,
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              label: 'Персонажи',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_border),
              label: 'Избранное',
            ),
          ],
        ),
      ),
    );
  }
}
