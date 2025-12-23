import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:rick_morty_characters/data/local/hive_boxes.dart';
import 'package:rick_morty_characters/data/models/character.dart';

class CharactersCacheStore {
  CharactersCacheStore(this._box);

  final Box _box;

  static const _keyItems = 'items_json';

  List<Character> load() {
    final raw = _box.get(_keyItems);
    if (raw is String && raw.isNotEmpty) {
      final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(Character.fromJson).toList();
    }
    return <Character>[];
  }

  void save(List<Character> items) {
    final jsonList = items
        .map((c) => {
              'id': c.id,
              'name': c.name,
              'status': c.status,
              'species': c.species,
              'image': c.image,
              'location': {'name': c.locationName},
            })
        .toList();

    _box.put(_keyItems, json.encode(jsonList));
  }

  void clear() {
    _box.delete(_keyItems);
  }
}
