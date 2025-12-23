import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:rick_morty_characters/data/local/hive_boxes.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore(this._box);

  final Box _box;

  static const _keyIds = 'favorite_ids';

  Set<int> get ids {
    final raw = _box.get(_keyIds);
    if (raw is List) {
      return raw.whereType<int>().toSet();
    }
    return <int>{};
  }

  bool isFavorite(int id) => ids.contains(id);

  void toggle(int id) {
    final current = ids;
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    _box.put(_keyIds, current.toList());
    notifyListeners();
  }

  void remove(int id) {
    final current = ids;
    if (current.remove(id)) {
      _box.put(_keyIds, current.toList());
      notifyListeners();
    }
  }
}
