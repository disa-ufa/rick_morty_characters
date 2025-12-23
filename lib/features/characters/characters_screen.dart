import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rick_morty_characters/features/favorites/favorites_store.dart';
import 'characters_provider.dart';

class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController _controller;

  Timer? _offlineTimer;
  bool _offlineBannerVisible = false;
  bool? _lastOffline; // чтобы реагировать только на изменения

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _controller = ScrollController()
      ..addListener(() {
        final position = _controller.position;
        if (position.pixels >= position.maxScrollExtent - 300) {
          context.read<CharactersProvider>().loadMore();
        }
      });

    Future.microtask(() => context.read<CharactersProvider>().ensureLoaded());
  }

  @override
  void dispose() {
    _offlineTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _syncOfflineBanner(bool offline) {
    if (_lastOffline == offline) return;
    _lastOffline = offline;

    if (!offline) {
      _offlineTimer?.cancel();
      if (_offlineBannerVisible) {
        setState(() => _offlineBannerVisible = false);
      }
      return;
    }

    _offlineTimer?.cancel();
    _offlineTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (_lastOffline == true && !_offlineBannerVisible) {
        setState(() => _offlineBannerVisible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final provider = context.watch<CharactersProvider>();
    final favorites = context.watch<FavoritesStore>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncOfflineBanner(provider.offline);
    });

    if (provider.loading && provider.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ошибка загрузки'),
              const SizedBox(height: 8),
              Text(provider.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: provider.loadFirstPage,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_offlineBannerVisible)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: Colors.orange.withOpacity(0.25),
            child: const Text(
              'Оффлайн: показаны сохранённые данные (кэш)',
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _controller,
            itemCount: provider.items.length + (provider.loadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= provider.items.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final c = provider.items[index];
              final isFav = favorites.isFavorite(c.id);

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
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 90,
                              height: 90,
                              color: Colors.black12,
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
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
                        tooltip: isFav ? 'Убрать из избранного' : 'В избранное',
                        onPressed: () => favorites.toggle(c.id),
                        icon: Icon(isFav ? Icons.star : Icons.star_border),
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
