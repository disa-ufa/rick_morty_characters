import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rick_morty_characters/features/characters/characters_provider.dart';
import 'package:rick_morty_characters/features/favorites/favorites_store.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _asc = true;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesStore>();
    final characters = context.watch<CharactersProvider>().items;

    final favIds = favorites.ids;

    final favItems = characters.where((c) => favIds.contains(c.id)).toList()
      ..sort((a, b) => _asc
          ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
          : b.name.toLowerCase().compareTo(a.name.toLowerCase()));

    if (favIds.isEmpty) {
      return const Center(
        child: Text('Избранное пусто. Нажми ⭐ у персонажа.'),
      );
    }

    // Если избранное есть, но персонажи ещё не загружены/не попали в список
    if (favItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Избранные есть, но данные персонажей ещё не загружены.\n'
            'Открой вкладку "Персонажи", чтобы загрузить список.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: Row(
            children: [
              const Text('Сортировка:'),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => setState(() => _asc = !_asc),
                icon: Icon(_asc ? Icons.arrow_upward : Icons.arrow_downward),
                label: Text(_asc ? 'Имя (A→Z)' : 'Имя (Z→A)'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: favItems.length,
            itemBuilder: (context, index) {
              final c = favItems[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          c.image,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text('Статус: ${c.status}'),
                            Text('Вид: ${c.species}'),
                            Text('Локация: ${c.locationName}'),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Удалить из избранного',
                        onPressed: () => favorites.remove(c.id),
                        icon: const Icon(Icons.star),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
