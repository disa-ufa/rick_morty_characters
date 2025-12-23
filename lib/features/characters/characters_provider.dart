import 'package:flutter/foundation.dart';

import 'package:rick_morty_characters/data/local/characters_cache_store.dart';
import 'package:rick_morty_characters/data/models/character.dart';
import 'package:rick_morty_characters/data/remote/rick_morty_api.dart';

class CharactersProvider extends ChangeNotifier {
  CharactersProvider(this._api, this._cache);

  final RickMortyApi _api;
  final CharactersCacheStore _cache;

  final List<Character> _items = [];
  List<Character> get items => List.unmodifiable(_items);

  int _page = 1;
  bool _hasNext = true;

  bool _loading = false;
  bool get loading => _loading;

  bool _loadingMore = false;
  bool get loadingMore => _loadingMore;

  bool _fromCache = false;
  bool get fromCache => _fromCache;

  bool _offline = false;
  bool get offline => _offline;

  String? _error;
  String? get error => _error;

  static const int _pageSize = 20;

  Future<void> ensureLoaded() async {
    if (_items.isNotEmpty) return;
    await loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    _loading = true;
    _loadingMore = false;
    _error = null;
    _offline = false;
    _page = 1;
    _hasNext = true;

    // 1) Сначала показываем кэш (если есть)
    final cached = _cache.load();
    if (cached.isNotEmpty) {
      _items
        ..clear()
        ..addAll(cached);

      _fromCache = true;

      // подстрахуем page по размеру кэша, чтобы пагинация не начиналась заново с 2 страницы
      _page = ((_items.length - 1) ~/ _pageSize) + 1;
    } else {
      _fromCache = false;
      _page = 1;
    }

    notifyListeners();

    try {
      // 2) Затем пробуем обновить 1 страницу из сети
      final pageData = await _api.fetchCharacters(page: 1);

      final firstPage = pageData.results;

      // сохраняем его, чтобы избранное не "пропадало".
      final firstIds = firstPage.map((e) => e.id).toSet();
      final tail = _items.where((c) => !firstIds.contains(c.id)).toList();

      _items
        ..clear()
        ..addAll(firstPage)
        ..addAll(tail);

      _hasNext = pageData.hasNext;

      _offline = false;
      _fromCache = false;

      // page пересчитываем по итоговой длине, чтобы loadMore продолжал корректно
      _page = ((_items.length - 1) ~/ _pageSize) + 1;

      _cache.save(_items);
    } catch (e) {
      _error = e.toString();
      _offline = true;

      // если кэш/данные уже есть — остаёмся на них
      if (_items.isNotEmpty) {
        _fromCache = true;
        _hasNext = false; // в оффлайне дальше не грузим
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_loading || _loadingMore || !_hasNext) return;

    _loadingMore = true;
    _error = null;
    notifyListeners();

    try {
      final nextPage = _page + 1;
      final pageData = await _api.fetchCharacters(page: nextPage);

      _page = nextPage;
      _hasNext = pageData.hasNext;

      final existingIds = _items.map((e) => e.id).toSet();
      final newOnes = pageData.results.where((c) => !existingIds.contains(c.id));

      _items.addAll(newOnes);

      _offline = false;
      _fromCache = false;

      _cache.save(_items);
    } catch (e) {
      _error = e.toString();
      _offline = true;
      _fromCache = true;
      _hasNext = false;
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }
}
