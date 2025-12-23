import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'data/local/hive_boxes.dart';
import 'data/settings/settings_store.dart';

import 'package:rick_morty_characters/data/remote/rick_morty_api.dart';
import 'package:rick_morty_characters/features/characters/characters_provider.dart';

import 'package:rick_morty_characters/features/favorites/favorites_store.dart';

import 'package:rick_morty_characters/data/local/characters_cache_store.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final settingsBox = await Hive.openBox(HiveBoxes.settings);
  final favoritesBox = await Hive.openBox(HiveBoxes.favorites);

  final charactersCacheBox = await Hive.openBox(HiveBoxes.charactersCache);

  runApp(
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => SettingsStore(settingsBox)),
    ChangeNotifierProvider(
  create: (_) => CharactersProvider(
    RickMortyApi(),
    CharactersCacheStore(charactersCacheBox),
  ),
),

    ChangeNotifierProvider(create: (_) => FavoritesStore(favoritesBox)),
  ],
  child: const App(),
),

  );
}
